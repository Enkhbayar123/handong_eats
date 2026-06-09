import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyB2-1BuDl1amDme42sjZoSNGd_I9pesWw8',
  appId: '1:457484292778:web:fc79f706d3af330dc0f6d3',
  messagingSenderId: '457484292778',
  projectId: 'handong-eats-61f3d',
  authDomain: 'handong-eats-61f3d.firebaseapp.com',
  storageBucket: 'handong-eats-61f3d.firebasestorage.app',
  measurementId: 'G-EKWMD8N1HL'
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
