function scrollTrigger(selector) {
  let els = document.querySelectorAll(selector);
  els = Array.from(els);

  let observer = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('active');
        observer.unobserve(entry.target);
      }
    });
  }, {
    root: null,
    rootMargin: '0px',
    threshold: 0.1
  });

  els.forEach(el => {
    observer.observe(el);
  });
}

// Example usage
document.addEventListener('DOMContentLoaded', function() {
  scrollTrigger('.scroll-reveal');
});

// Video Modal Handler
document.addEventListener('DOMContentLoaded', function() {
  const videoModal = document.getElementById('videoModal');
  if (!videoModal) return;

  // Check for video ID in URL hash on page load
  const videoId = window.location.hash.slice(1);
  if (videoId) openVideoModal(videoId);

  // Handle modal opening
  videoModal.addEventListener('show.bs.modal', event => {
    const button = event.relatedTarget;
    const videoId = button.dataset.videoId;
    const videoTitle = button.dataset.videoTitle;

    updateModalContent(videoModal, videoId, videoTitle);
    window.history.pushState({}, '', `#${videoId}`);
  });

  // Handle modal closing
  videoModal.addEventListener('hidden.bs.modal', () => {
    window.history.pushState({}, '', window.location.pathname);
    videoModal.querySelector('iframe').src = '';
  });
});

function updateModalContent(modal, videoId, videoTitle) {
  modal.querySelector('.modal-title').textContent = videoTitle;
  modal.querySelector('iframe').src = getVimeoEmbedUrl(videoId);
}

function getVimeoEmbedUrl(videoId) {
  return `https://player.vimeo.com/video/${videoId}?autoplay=1&title=1&byline=0&portrait=0&controls=1&share=1&pip=0&speed=0&quality=0&collections=0&info=0`;
}

function openVideoModal(videoId) {
  const button = document.querySelector(`[data-video-id="${videoId}"]`);
  if (!button) return;

  const modal = new bootstrap.Modal(videoModal);
  updateModalContent(videoModal, videoId, button.dataset.videoTitle);
  modal.show();
}

document.addEventListener('DOMContentLoaded', function() {
  // Initialize Justified Gallery
  $("#gallery").justifiedGallery({
    rowHeight: 300,
    margins: 5,
    lastRow: 'justify',
    border: 0,
    captions: false,
    waitThumbnailsLoad: true
  }).on('jg.complete', function() {
    let lightbox = new PhotoSwipeLightbox({
      gallery: '#gallery',
      children: 'a',
      pswpModule: PhotoSwipe,
      closeOnVerticalDrag: true,
      clickToCloseNonZoomable: false,
      imageClickAction: 'zoom',
      tapAction: 'zoom',
      doubleTapAction: 'zoom',
      bgOpacity: 0.8,
      showHideAnimationType: 'fade'
    });

    lightbox.init();
  });
});

// Video Card Button Handler
document.querySelectorAll('.album-button').forEach(button => {
  button.addEventListener('click', function() {
    const newAlbumId = this.getAttribute('data-album-id');
    // Update the ALBUM_ID and fetch videos again
    // This part depends on how you want to handle the fetch and update
    console.log('New Album ID:', newAlbumId);
    // Example: fetch_vimeo_videos(newAlbumId);
  });
});
