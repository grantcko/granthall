// import modules
import {resetBunnyVideoPlayerOnModalClose, manageVideoURLHash } from './videoModal.js';
import { initializePhotoGallery } from './photoGallery.js';
import { scrollTrigger } from './writeAnimate.js';
import { initializeAlbumFilter } from './videoTagFilter.js';

document.addEventListener('DOMContentLoaded', function() {
  manageVideoURLHash();
  resetBunnyVideoPlayerOnModalClose();
  initializeAlbumFilter();
  scrollTrigger('.scroll-reveal');
  initializePhotoGallery();
});
