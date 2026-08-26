// Simple Service Worker for PWA installability
const CACHE_NAME = 'snake-magic-v1';

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(clients.claim());
});

self.addEventListener('fetch', (event) => {
  // Pass-through strategy: just fetch from network
  event.respondWith(fetch(event.request));
});
