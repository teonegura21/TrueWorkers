/**
 * MESTERI LANDING PAGE - MAIN JAVASCRIPT
 * Interactive features and animations
 */

// ========================================
// INITIALIZATION
// ========================================
document.addEventListener('DOMContentLoaded', () => {
  initNavbar();
  initMobileMenu();
  initScrollAnimations();
  initCounterAnimations();
  initAudienceToggle();
  initFAQ();
  initScrollToTop();
  initContactForm();
  initSmoothScroll();
});

// ========================================
// NAVBAR SCROLL EFFECT
// ========================================
function initNavbar() {
  const navbar = document.getElementById('navbar');
  let lastScroll = 0;

  window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    // Add scrolled class when scrolling down
    if (currentScroll > 50) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }

    lastScroll = currentScroll;
  });
}

// ========================================
// MOBILE MENU TOGGLE
// ========================================
function initMobileMenu() {
  const toggleBtn = document.getElementById('mobileMenuToggle');
  const navLinks = document.getElementById('navLinks');
  const navbar = document.getElementById('navbar');

  if (!toggleBtn) return;

  toggleBtn.addEventListener('click', () => {
    navLinks.classList.toggle('mobile-open');

    // Toggle icon
    const icon = toggleBtn.querySelector('i');
    if (icon.classList.contains('fa-bars')) {
      icon.classList.remove('fa-bars');
      icon.classList.add('fa-times');
    } else {
      icon.classList.remove('fa-times');
      icon.classList.add('fa-bars');
    }
  });

  // Close menu when clicking on a link
  const links = navLinks.querySelectorAll('a');
  links.forEach(link => {
    link.addEventListener('click', () => {
      navLinks.classList.remove('mobile-open');
      const icon = toggleBtn.querySelector('i');
      icon.classList.remove('fa-times');
      icon.classList.add('fa-bars');
    });
  });

  // Close menu when clicking outside
  document.addEventListener('click', (e) => {
    if (!navbar.contains(e.target)) {
      navLinks.classList.remove('mobile-open');
      const icon = toggleBtn.querySelector('i');
      icon.classList.remove('fa-times');
      icon.classList.add('fa-bars');
    }
  });
}

// ========================================
// SCROLL ANIMATIONS
// ========================================
function initScrollAnimations() {
  const observerOptions = {
    root: null,
    rootMargin: '0px',
    threshold: 0.1
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animate-in');

        // For cards, stagger the animation
        if (entry.target.classList.contains('problem-card') ||
            entry.target.classList.contains('solution-card') ||
            entry.target.classList.contains('feature-card') ||
            entry.target.classList.contains('testimonial-card') ||
            entry.target.classList.contains('step-card')) {
          const cards = entry.target.parentElement.querySelectorAll(
            '.problem-card, .solution-card, .feature-card, .testimonial-card, .step-card'
          );
          cards.forEach((card, index) => {
            setTimeout(() => {
              card.style.animation = `fadeInUp 0.6s ease-out forwards`;
              card.style.animationDelay = `${index * 0.1}s`;
            }, 0);
          });
        }
      }
    });
  }, observerOptions);

  // Observe all cards
  const animatedElements = document.querySelectorAll(`
    .problem-card,
    .solution-card,
    .feature-card,
    .testimonial-card,
    .step-card,
    .pricing-card
  `);

  animatedElements.forEach(el => {
    el.style.opacity = '0';
    observer.observe(el);
  });
}

// ========================================
// COUNTER ANIMATIONS
// ========================================
function initCounterAnimations() {
  const counters = document.querySelectorAll('[data-target]');
  const speed = 200; // Animation speed

  const observerOptions = {
    root: null,
    rootMargin: '0px',
    threshold: 0.5
  };

  const animateCounter = (counter) => {
    const target = +counter.getAttribute('data-target');
    const count = +counter.innerText.replace(/[^0-9.]/g, '');
    const increment = target / speed;

    if (count < target) {
      counter.innerText = Math.ceil(count + increment);
      setTimeout(() => animateCounter(counter), 10);
    } else {
      // Format final number
      if (target >= 1000) {
        counter.innerText = target.toLocaleString('ro-RO');
      } else {
        counter.innerText = target;
      }
    }
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting && !entry.target.classList.contains('counted')) {
        entry.target.classList.add('counted');
        animateCounter(entry.target);
      }
    });
  }, observerOptions);

  counters.forEach(counter => {
    observer.observe(counter);
  });
}

// ========================================
// AUDIENCE TOGGLE (How It Works Section)
// ========================================
function initAudienceToggle() {
  const toggleBtns = document.querySelectorAll('.toggle-btn');
  const clientSteps = document.getElementById('client-steps');
  const craftsmanSteps = document.getElementById('craftsman-steps');

  if (!toggleBtns.length) return;

  toggleBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const audience = btn.getAttribute('data-audience');

      // Update active button
      toggleBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      // Show/hide steps
      if (audience === 'client') {
        clientSteps.classList.add('active');
        craftsmanSteps.classList.remove('active');
      } else {
        craftsmanSteps.classList.add('active');
        clientSteps.classList.remove('active');
      }
    });
  });
}

// ========================================
// FAQ ACCORDION
// ========================================
function initFAQ() {
  const faqItems = document.querySelectorAll('.faq-item');

  faqItems.forEach(item => {
    const question = item.querySelector('.faq-question');

    question.addEventListener('click', () => {
      const isActive = item.classList.contains('active');

      // Close all other items
      faqItems.forEach(i => i.classList.remove('active'));

      // Toggle current item
      if (!isActive) {
        item.classList.add('active');
      }
    });
  });
}

// ========================================
// SCROLL TO TOP BUTTON
// ========================================
function initScrollToTop() {
  const scrollBtn = document.getElementById('scrollToTop');

  if (!scrollBtn) return;

  window.addEventListener('scroll', () => {
    if (window.pageYOffset > 300) {
      scrollBtn.classList.add('visible');
    } else {
      scrollBtn.classList.remove('visible');
    }
  });

  scrollBtn.addEventListener('click', () => {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    });
  });
}

// ========================================
// CONTACT FORM
// ========================================
function initContactForm() {
  const form = document.getElementById('contactForm');

  if (!form) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const submitBtn = form.querySelector('.btn-submit');
    const originalText = submitBtn.innerHTML;

    // Show loading state
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Se trimite...';
    submitBtn.disabled = true;

    // Get form data
    const formData = {
      name: form.name.value,
      email: form.email.value,
      phone: form.phone.value,
      subject: form.subject.value,
      message: form.message.value,
      timestamp: new Date().toISOString()
    };

    try {
      // Simulate API call (replace with actual endpoint)
      await new Promise(resolve => setTimeout(resolve, 1500));

      // Log to console (in production, send to backend)
      console.log('Form submission:', formData);

      // Show success message
      showNotification('success', 'Mesaj trimis cu succes! Vă vom contacta în curând.');

      // Reset form
      form.reset();
    } catch (error) {
      console.error('Form submission error:', error);
      showNotification('error', 'A apărut o eroare. Vă rugăm încercați din nou.');
    } finally {
      // Restore button
      submitBtn.innerHTML = originalText;
      submitBtn.disabled = false;
    }
  });
}

// ========================================
// NOTIFICATION SYSTEM
// ========================================
function showNotification(type, message) {
  // Create notification element
  const notification = document.createElement('div');
  notification.className = `notification notification-${type}`;
  notification.style.cssText = `
    position: fixed;
    top: 100px;
    right: 20px;
    background: ${type === 'success' ? '#10B981' : '#EF4444'};
    color: white;
    padding: 1rem 1.5rem;
    border-radius: 0.75rem;
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
    z-index: 9999;
    display: flex;
    align-items: center;
    gap: 0.75rem;
    max-width: 400px;
    animation: slideInRight 0.3s ease-out;
  `;

  notification.innerHTML = `
    <i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-circle'}"></i>
    <span>${message}</span>
  `;

  document.body.appendChild(notification);

  // Auto remove after 5 seconds
  setTimeout(() => {
    notification.style.animation = 'slideOutRight 0.3s ease-out';
    setTimeout(() => notification.remove(), 300);
  }, 5000);
}

// Add notification animations to CSS dynamically
const style = document.createElement('style');
style.textContent = `
  @keyframes slideInRight {
    from {
      transform: translateX(100%);
      opacity: 0;
    }
    to {
      transform: translateX(0);
      opacity: 1;
    }
  }
  @keyframes slideOutRight {
    from {
      transform: translateX(0);
      opacity: 1;
    }
    to {
      transform: translateX(100%);
      opacity: 0;
    }
  }
`;
document.head.appendChild(style);

// ========================================
// SMOOTH SCROLL
// ========================================
function initSmoothScroll() {
  const links = document.querySelectorAll('a[href^="#"]');

  links.forEach(link => {
    link.addEventListener('click', (e) => {
      const href = link.getAttribute('href');

      // Skip if it's just "#"
      if (href === '#') return;

      e.preventDefault();

      const target = document.querySelector(href);
      if (target) {
        const offsetTop = target.offsetTop - 80; // Account for fixed navbar

        window.scrollTo({
          top: offsetTop,
          behavior: 'smooth'
        });
      }
    });
  });
}

// ========================================
// HELPER FUNCTIONS
// ========================================

/**
 * Scroll to a specific section
 * @param {string} sectionId - The ID of the section to scroll to
 */
function scrollToSection(sectionId) {
  const section = document.getElementById(sectionId);
  if (section) {
    const offsetTop = section.offsetTop - 80;
    window.scrollTo({
      top: offsetTop,
      behavior: 'smooth'
    });
  }
}

/**
 * Scroll to download section
 */
function scrollToDownload() {
  scrollToSection('download');
}

// Make functions available globally
window.scrollToSection = scrollToSection;
window.scrollToDownload = scrollToDownload;

// ========================================
// PERFORMANCE MONITORING
// ========================================
window.addEventListener('load', () => {
  // Log performance metrics
  if (window.performance) {
    const perfData = window.performance.timing;
    const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;

    console.log(`%c🚀 Page loaded in ${pageLoadTime}ms`, 'color: #10B981; font-weight: bold; font-size: 14px;');

    // Log Core Web Vitals if available
    if ('PerformanceObserver' in window) {
      try {
        // Largest Contentful Paint (LCP)
        new PerformanceObserver((entryList) => {
          const entries = entryList.getEntries();
          const lastEntry = entries[entries.length - 1];
          console.log(`%cLCP: ${lastEntry.renderTime || lastEntry.loadTime}ms`, 'color: #3B82F6;');
        }).observe({ entryTypes: ['largest-contentful-paint'] });

        // First Input Delay (FID)
        new PerformanceObserver((entryList) => {
          const entries = entryList.getEntries();
          entries.forEach(entry => {
            console.log(`%cFID: ${entry.processingStart - entry.startTime}ms`, 'color: #8B5CF6;');
          });
        }).observe({ entryTypes: ['first-input'] });

        // Cumulative Layout Shift (CLS)
        let clsValue = 0;
        new PerformanceObserver((entryList) => {
          const entries = entryList.getEntries();
          entries.forEach(entry => {
            if (!entry.hadRecentInput) {
              clsValue += entry.value;
            }
          });
          console.log(`%cCLS: ${clsValue.toFixed(3)}`, 'color: #F59E0B;');
        }).observe({ entryTypes: ['layout-shift'] });
      } catch (e) {
        // PerformanceObserver not fully supported
      }
    }
  }
});

// ========================================
// EASTER EGG (Developer Console Message)
// ========================================
console.log(`
%c🔨 MESTERI PLATFORM %c

Prima platformă românească de încredere pentru meșteri verificați!

%c💻 Dezvoltat cu ❤️ de Teodor Negura
%c🚀 Powered by NestJS + Flutter + PostgreSQL
%c🎨 Design inspirat de Airbnb, Stripe & Linear

%cCaută meșteri? Înregistrează-te: https://mesteri.ro
Ești meșter? Creează profil: https://mesteri.ro/mestert

`,
  'background: linear-gradient(135deg, #4F46E5, #10B981); color: white; font-size: 20px; font-weight: bold; padding: 10px 20px; border-radius: 5px;',
  '',
  'color: #4F46E5; font-size: 12px;',
  'color: #10B981; font-size: 12px;',
  'color: #F59E0B; font-size: 12px;',
  'color: #6B7280; font-size: 12px; font-style: italic;'
);

// ========================================
// ANALYTICS (Placeholder for Google Analytics)
// ========================================
function trackEvent(category, action, label, value) {
  // Placeholder for analytics tracking
  if (window.gtag) {
    window.gtag('event', action, {
      event_category: category,
      event_label: label,
      value: value
    });
  }

  console.log('Analytics Event:', { category, action, label, value });
}

// Track CTA button clicks
document.querySelectorAll('[onclick*="scrollToDownload"]').forEach(btn => {
  btn.addEventListener('click', () => {
    trackEvent('CTA', 'click', 'Download App Button', 1);
  });
});

// Track section visibility
const sections = document.querySelectorAll('section[id]');
const sectionObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      trackEvent('Section View', 'scroll', entry.target.id, 1);
    }
  });
}, { threshold: 0.5 });

sections.forEach(section => sectionObserver.observe(section));

// ========================================
// ACCESSIBILITY ENHANCEMENTS
// ========================================

// Add keyboard navigation for cards
document.querySelectorAll('.feature-card, .problem-card, .solution-card').forEach(card => {
  card.setAttribute('tabindex', '0');

  card.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
      card.click();
    }
  });
});

// Add focus visible styles
document.addEventListener('keydown', (e) => {
  if (e.key === 'Tab') {
    document.body.classList.add('keyboard-nav');
  }
});

document.addEventListener('mousedown', () => {
  document.body.classList.remove('keyboard-nav');
});

// Add keyboard navigation styles
const keyboardNavStyle = document.createElement('style');
keyboardNavStyle.textContent = `
  .keyboard-nav *:focus {
    outline: 3px solid #4F46E5;
    outline-offset: 2px;
  }
`;
document.head.appendChild(keyboardNavStyle);

// ========================================
// PREFETCH RESOURCES
// ========================================
window.addEventListener('load', () => {
  // Prefetch download page resources
  const prefetchLink = document.createElement('link');
  prefetchLink.rel = 'prefetch';
  prefetchLink.href = '/download'; // Adjust URL as needed
  document.head.appendChild(prefetchLink);
});

// ========================================
// ERROR HANDLING
// ========================================
window.addEventListener('error', (e) => {
  console.error('Global error:', e.error);

  // Log to error tracking service (e.g., Sentry)
  // Sentry.captureException(e.error);
});

window.addEventListener('unhandledrejection', (e) => {
  console.error('Unhandled promise rejection:', e.reason);

  // Log to error tracking service
  // Sentry.captureException(e.reason);
});

console.log('%c✅ Mesteri Landing Page - JavaScript Initialized', 'color: #10B981; font-weight: bold; font-size: 14px;');
