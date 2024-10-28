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
  if (videoModal) {
    videoModal.addEventListener('show.bs.modal', event => {
      const button = event.relatedTarget;
      const videoId = button.dataset.videoId;
      const videoTitle = button.dataset.videoTitle;
      videoModal.querySelector('.modal-title').textContent = videoTitle;
      videoModal.querySelector('iframe').src = `https://player.vimeo.com/video/${videoId}?autoplay=1&title=1&byline=0&portrait=0&controls=1&share=1&pip=0&speed=0&quality=0&collections=0&info=0`;
    });

    videoModal.addEventListener('hidden.bs.modal', () => {
      videoModal.querySelector('iframe').src = '';
    });
  }
});

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
