import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { 
  collection, 
  addDoc, 
  onSnapshot, 
  query, 
  orderBy, 
  limit, 
  deleteDoc, 
  doc,
  Timestamp 
} from 'firebase/firestore';
import { 
  Plus, 
  Trash2, 
  Utensils, 
  ChefHat, 
  Image, 
  Info, 
  Coins, 
  Flame, 
  LogOut, 
  Sparkles, 
  CheckCircle,
  FileText
} from 'lucide-react';

const RESTAURANTS = [
  { id: 'rest_1', name: "Mom's Kitchen (맘스키친)" },
  { id: 'rest_2', name: "Student Lounge (Sola Fide)" },
  { id: 'rest_3', name: "Student Lounge (Goshen)" },
  { id: 'rest_4', name: "Myeongsong" },
  { id: 'rest_5', name: "Grace Table" },
  { id: 'rest_6', name: "Dasu Handong" },
  { id: 'rest_7', name: "Deun Deun (Student Bento)" },
  { id: 'rest_8', name: "Korean Table" }
];
const getImageUrl = (url) => {
  let resolvedUrl = '/lib/images/KakaoTalk_Photo_2026-05-30-22-04-17 001.jpeg';
  if (url) {
    if (url.startsWith('http')) {
      resolvedUrl = url;
    } else if (url.startsWith('lib/images/')) {
      resolvedUrl = '/' + url;
    }
  }
  return encodeURI(resolvedUrl);
};

const getPresetUrlForName = (name) => {
  const norm = name.trim().toLowerCase();
  if (norm.includes('soondubu')) return 'lib/images/KakaoTalk_Photo_2026-05-30-22-04-17 001.jpeg';
  if (norm.includes('cutlet') || norm.includes('tonkatsu') || norm.includes('pork')) return 'lib/images/KakaoTalk_Photo_2026-05-30-22-04-18 002.jpeg';
  if (norm.includes('tteok')) return 'lib/images/KakaoTalk_Photo_2026-05-30-22-04-18 003.jpeg';
  if (norm.includes('tansuyuk')) return 'lib/images/KakaoTalk_Photo_2026-05-30-22-04-19 004.jpeg';
  if (norm.includes('ramen') || norm.includes('ramyeon')) return 'lib/images/KakaoTalk_Photo_2026-05-30-22-04-53 012.jpeg';
  if (norm.includes('dakganjon') || norm.includes('kanjon') || norm.includes('chicken')) return 'lib/images/KakaoTalk_Photo_2026-05-30-22-04-53 013.jpeg';
  return 'lib/images/KakaoTalk_Photo_2026-05-30-22-04-17 001.jpeg';
};

export default function Portal({ onLogout }) {
  const [restaurantId, setRestaurantId] = useState('rest_1');
  const [dishName, setDishName] = useState('');
  const [price, setPrice] = useState('');
  const [portionSize, setPortionSize] = useState('Small'); // For Jjajamyeon
  const [description, setDescription] = useState('');
  
  // Macros state removed (Dynamically calculated by AI on the mobile application)

  const [menuItems, setMenuItems] = useState([]);
  const [reviews, setReviews] = useState([]);
  const [users, setUsers] = useState({});
  const [isLoading, setIsLoading] = useState(false);
  const [successMsg, setSuccessMsg] = useState('');
  const [errorMsg, setErrorMsg] = useState('');

  // 1. Listen to Firestore menu_items in real time
  useEffect(() => {
    const q = query(
      collection(db, 'menu_items'),
    );
    
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const items = [];
      snapshot.forEach((doc) => {
        items.push({ id: doc.id, ...doc.data() });
      });
      items.sort((a, b) => {
        const timeA = a.createdAt instanceof Timestamp ? a.createdAt.toMillis() : 0;
        const timeB = b.createdAt instanceof Timestamp ? b.createdAt.toMillis() : 0;
        return timeB - timeA;
      });
      setMenuItems(items);
    }, (error) => {
      console.error("Firestore error:", error);
    });

    return () => unsubscribe();
  }, []);

  // 1b. Listen to Firestore reviews in real time
  useEffect(() => {
    const q = query(collection(db, 'reviews'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const revs = [];
      snapshot.forEach((doc) => {
        revs.push({ id: doc.id, ...doc.data() });
      });
      setReviews(revs);
    }, (error) => {
      console.error("Reviews listener error:", error);
    });
    return () => unsubscribe();
  }, []);

  // 1c. Listen to Firestore users in real time
  useEffect(() => {
    const q = query(collection(db, 'users'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const usrMap = {};
      snapshot.forEach((doc) => {
        usrMap[doc.id] = { id: doc.id, ...doc.data() };
      });
      setUsers(usrMap);
    }, (error) => {
      console.error("Users listener error:", error);
    });
    return () => unsubscribe();
  }, []);

  const getBestReviewImage = (menuItemId, fallbackUrl) => {
    const candidates = reviews.filter(r => 
      r.menuItemId === menuItemId && 
      r.backgroundImageUrl && 
      r.backgroundImageUrl.trim() !== ''
    );

    if (candidates.length === 0) {
      return fallbackUrl || 'lib/images/KakaoTalk_Photo_2026-05-30-22-04-17 001.jpeg';
    }

    candidates.sort((a, b) => {
      const likesA = a.likesCount || (a.likedBy ? a.likedBy.length : 0) || 0;
      const likesB = b.likesCount || (b.likedBy ? b.likedBy.length : 0) || 0;
      if (likesB !== likesA) return likesB - likesA;

      const userA = users[a.userId] || {};
      const userB = users[b.userId] || {};
      const countA = userA.reviewCount || 0;
      const countB = userB.reviewCount || 0;
      if (countB !== countA) return countB - countA;

      const dateA = a.datePosted ? (a.datePosted.seconds || new Date(a.datePosted).getTime()) : 0;
      const dateB = b.datePosted ? (b.datePosted.seconds || new Date(b.datePosted).getTime()) : 0;
      return dateB - dateA;
    });

    return candidates[0].backgroundImageUrl;
  };

  // 2. React to restaurant changes or name changes to apply dynamic default values
  useEffect(() => {
    // A. Mom's Kitchen
    if (restaurantId === 'rest_1') {
      setPrice('4500');
      return;
    }

    // B. Student Lounge (Sola Fide)
    if (restaurantId === 'rest_2') {
      const normalizedName = dishName.trim().toLowerCase();
      if (normalizedName === 'tansuyuk') {
        setPrice('8500');
      } else if (normalizedName === 'dakganjon' || normalizedName === 'dakkanjon') {
        setPrice('10000');
      } else if (normalizedName === 'jjanbon' || normalizedName === 'jjanbbun') {
        setPrice('6500');
      } else if (normalizedName === 'jjajamyeon') {
        setPrice(portionSize === 'Small' ? '5500' : '6500');
      } else {
        // No specific rule match, do not override existing input unless it was one of the matching rules
        if (['8500', '10000', '6500', '5500'].includes(price)) {
          setPrice('');
        }
      }
      return;
    }

    // C. Student Lounge (Goshen)
    if (restaurantId === 'rest_3') {
      const normalizedName = dishName.trim().toLowerCase();
      if (normalizedName === 'duejigukbab' || normalizedName === 'tuejigukbab') {
        setPrice('6500');
      } else if (normalizedName === 'soondubu jjigae' || normalizedName === 'soondubu') {
        setPrice('6500');
      } else if (normalizedName === 'budae jjigae' || normalizedName === 'budaejjigae') {
        setPrice('6500');
      } else {
        if (price === '6500') {
          setPrice('');
        }
      }
      return;
    }

    // D. Others: No default values, clear rule-derived values to prevent spillover
    if (['4500', '8500', '10000', '6500', '5500'].includes(price)) {
      setPrice('');
    }
  }, [restaurantId, dishName, portionSize]);

  // Handle Form Submission
  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg('');
    setSuccessMsg('');

    if (!dishName.trim()) {
      setErrorMsg('Dish name is required.');
      return;
    }

    if (!price || parseFloat(price) <= 0) {
      setErrorMsg('Price must be a valid positive number.');
      return;
    }

    setIsLoading(true);

    try {
      const finalImage = getPresetUrlForName(dishName);
      const finalDescription = description.trim() || `Fresh and delicious ${dishName} prepared specifically for university dining.`;

      // Build data matching MenuItemModel
      const newDish = {
        restaurantId: restaurantId,
        name: dishName.trim(),
        price: parseInt(price, 10),
        imageUrl: finalImage,
        description: finalDescription,
        averageRating: 5.0, // Brand new dish starts with full rating
        reviewCount: 0,
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        createdAt: Timestamp.now() // Track when it was added
      };

      await addDoc(collection(db, 'menu_items'), newDish);
      
      // Success response & reset input form fields
      setSuccessMsg(`Successfully added "${dishName.trim()}"!`);
      setDishName('');
      setPrice('');
      setDescription('');
      setPortionSize('Small');
      
      // Hide success message after 4s
      setTimeout(() => setSuccessMsg(''), 4000);
    } catch (err) {
      console.error(err);
      setErrorMsg('Failed to save to database: ' + err.message);
    } finally {
      setIsLoading(false);
    }
  };

  // Handle Dish Deletion
  const handleDelete = async (id, name) => {
    if (window.confirm(`Are you sure you want to remove "${name}"?`)) {
      try {
        await deleteDoc(doc(db, 'menu_items', id));
        setSuccessMsg(`Removed "${name}" successfully.`);
        setTimeout(() => setSuccessMsg(''), 3000);
      } catch (err) {
        setErrorMsg('Failed to delete dish: ' + err.message);
      }
    }
  };

  const getRestaurantName = (id) => {
    const found = RESTAURANTS.find(r => r.id === id);
    return found ? found.name : 'Unknown Restaurant';
  };

  const isJjajamyeon = dishName.trim().toLowerCase() === 'jjajamyeon';

  return (
    <div className="portal-container fade-in">
      {/* Header bar */}
      <header className="portal-header glass-panel">
        <div className="portal-brand">
          <ChefHat className="brand-logo text-red animate-pulse" size={28} />
          <h2>Handong Eats <span className="badge">Official Partner Portal</span></h2>
        </div>
        <button className="logout-btn" onClick={onLogout}>
          <LogOut size={16} />
          <span>Sign Out</span>
        </button>
      </header>

      {/* Grid container */}
      <div className="portal-grid">
        {/* Left Side: Submission Workspace */}
        <section className="portal-workspace glass-panel">
          <div className="section-header">
            <Sparkles className="text-red" size={20} />
            <h3>Create New Menu Dish</h3>
          </div>

          <form onSubmit={handleSubmit} className="portal-form">
            {errorMsg && <div className="error-banner"><Info size={16} /> {errorMsg}</div>}
            {successMsg && <div className="success-banner"><CheckCircle size={16} /> {successMsg}</div>}

            {/* Restaurant Selector */}
            <div className="form-group">
              <label htmlFor="restaurant">Dining Hall / Cafeteria</label>
              <select 
                id="restaurant" 
                value={restaurantId} 
                onChange={(e) => setRestaurantId(e.target.value)}
              >
                {RESTAURANTS.map(r => (
                  <option key={r.id} value={r.id}>{r.name}</option>
                ))}
              </select>
            </div>

            {/* Food Name */}
            <div className="form-group">
              <label htmlFor="dishName">Food Menu Title</label>
              <div className="input-with-suggestions">
                <input
                  id="dishName"
                  type="text"
                  placeholder="e.g. Tansuyuk, Soondubu Jjigae, Ramen..."
                  value={dishName}
                  onChange={(e) => setDishName(e.target.value)}
                  autoComplete="off"
                />
                
                {/* Suggestions badges */}
                <div className="suggestions-bar">
                  <span className="suggestion-label">Try typing:</span>
                  {['Tansuyuk', 'Dakganjon', 'Jjanbon', 'Jjajamyeon', 'Soondubu Jjigae', 'Budae jjigae'].map(sugg => (
                    <button 
                      key={sugg} 
                      type="button" 
                      className="suggestion-tag"
                      onClick={() => setDishName(sugg)}
                    >
                      {sugg}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {/* Jjajamyeon Portion Option */}
            {isJjajamyeon && restaurantId === 'rest_2' && (
              <div className="form-group slide-down">
                <label>Portion Size (Sola Fide Rule)</label>
                <div className="portion-selector">
                  <label className={`portion-label ${portionSize === 'Small' ? 'active' : ''}`}>
                    <input 
                      type="radio" 
                      name="portion" 
                      value="Small" 
                      checked={portionSize === 'Small'} 
                      onChange={() => setPortionSize('Small')}
                    />
                    <span>Small Portion (5,500 KRW)</span>
                  </label>
                  <label className={`portion-label ${portionSize === 'Big' ? 'active' : ''}`}>
                    <input 
                      type="radio" 
                      name="portion" 
                      value="Big" 
                      checked={portionSize === 'Big'} 
                      onChange={() => setPortionSize('Big')}
                    />
                    <span>Big Portion (6,500 KRW)</span>
                  </label>
                </div>
              </div>
            )}

            {/* Price (KRW) */}
            <div className="form-group">
              <label htmlFor="price">Price (KRW)</label>
              <div className="price-input-wrapper">
                <Coins size={18} className="price-icon" />
                <input
                  id="price"
                  type="number"
                  placeholder="Enter menu price in Won"
                  value={price}
                  onChange={(e) => setPrice(e.target.value)}
                />
                
                {/* Dynamic Suggestion Notice */}
                {restaurantId === 'rest_1' && (
                  <span className="price-badge bg-red glow-text">Auto Mom's (4500)</span>
                )}
                {restaurantId === 'rest_2' && ['tansuyuk', 'dakganjon', 'dakkanjon', 'jjanbon', 'jjanbbun', 'jjajamyeon'].includes(dishName.trim().toLowerCase()) && (
                  <span className="price-badge bg-green glow-green">Sola Fide Default</span>
                )}
                {restaurantId === 'rest_3' && ['duejigukbab', 'tuejigukbab', 'soondubu jjigae', 'soondubu', 'budae jjigae', 'budaejjigae'].includes(dishName.trim().toLowerCase()) && (
                  <span className="price-badge bg-green glow-green">Goshen Default (6500)</span>
                )}
              </div>
            </div>

            {/* Image Upload/Presets Removed (Controlled by Review Photos) */}

            {/* Description */}
            <div className="form-group">
              <label htmlFor="description">Dish Description / Dietary Details</label>
              <textarea
                id="description"
                rows="2"
                placeholder="Briefly describe the culinary details, allergens or preparation (e.g. Healthy warm stew loaded with fresh pork belly, mushrooms and scallions)."
                value={description}
                onChange={(e) => setDescription(e.target.value)}
              />
            </div>

            {/* Nutritional Value Profile Removed (Controlled dynamically by AI) */}

            <button 
              type="submit" 
              className="btn-primary submit-dish-btn"
              disabled={isLoading}
            >
              {isLoading ? (
                <span className="loader-dots">Adding to Firestore...</span>
              ) : (
                <>
                  <Plus size={20} />
                  <span>Publish Menu Dish</span>
                </>
              )}
            </button>
          </form>
        </section>

        {/* Right Side: Recently Added (Live Sync Feed) */}
        <section className="portal-feed glass-panel">
          <div className="section-header">
            <Utensils className="text-red" size={20} />
            <h3>Live Menu Board ({menuItems.length})</h3>
          </div>

          <div className="feed-list">
            {menuItems.length === 0 ? (
              <div className="feed-empty-state">
                <FileText size={48} className="empty-icon" />
                <p>No dishes found in the database collection.</p>
                <span>Items added via this portal or Flutter seeder will appear here in real-time.</span>
              </div>
            ) : (
              menuItems.map((item) => (
                <div key={item.id} className="feed-card fade-in">
                  <div 
                    className="feed-card-image"
                    style={{ 
                      backgroundImage: `url("${getImageUrl(getBestReviewImage(item.id, item.imageUrl))}")` 
                    }}
                  />
                  <div className="feed-card-details">
                    <span className="feed-card-restaurant">{getRestaurantName(item.restaurantId)}</span>
                    <h4 className="feed-card-name">{item.name}</h4>
                    <div className="feed-card-pricing-rating">
                      <span className="feed-card-price">{item.price.toLocaleString()} KRW</span>
                      <span className="feed-card-rating">★ {item.averageRating || 5.0}</span>
                    </div>

                  </div>
                  <button 
                    className="delete-card-btn" 
                    onClick={() => handleDelete(item.id, item.name)}
                    title="Delete Menu Item"
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              ))
            )}
          </div>
        </section>
      </div>
    </div>
  );
}
