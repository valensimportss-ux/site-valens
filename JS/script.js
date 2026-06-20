// script.js – basic cart and WhatsApp integration

// Simple in‑memory cart
const cart = [];

function updateCartCount() {
  const countEl = document.querySelector('[data-cart-count]');
  if (countEl) countEl.textContent = cart.reduce((sum, i) => sum + i.qty, 0);
}

function renderCartItems() {
  const container = document.querySelector('[data-cart-items]');
  if (!container) return;
  container.innerHTML = '';
  if (cart.length === 0) {
    container.innerHTML = '<p class="empty-cart">Seu carrinho está vazio.</p>';
    return;
  }
  cart.forEach(item => {
    const div = document.createElement('div');
    div.className = 'cart-item';
    div.innerHTML = `
      <span class="item-name">${item.name}</span>
      <span class="item-qty">x${item.qty}</span>
      <span class="item-price">R$ ${(item.price * item.qty).toFixed(2)}</span>
    `;
    container.appendChild(div);
  });
  const total = cart.reduce((sum, i) => sum + i.price * i.qty, 0);
  document.querySelector('[data-cart-total]').textContent = `R$ ${total.toFixed(2)}`;
}

function addToCart(name, price) {
  const existing = cart.find(i => i.name === name);
  if (existing) {
    existing.qty += 1;
  } else {
    cart.push({ name, price: parseFloat(price), qty: 1 });
  }
  updateCartCount();
  renderCartItems();
}

function initAddToCartButtons() {
  document.querySelectorAll('.add-to-cart').forEach(btn => {
    btn.addEventListener('click', e => {
      const card = e.target.closest('.card');
      const name = card.dataset.productName;
      const price = card.dataset.productPrice.replace(',', '.');
      addToCart(name, price);
    });
  });
}

function initCartDrawer() {
  const toggle = document.querySelector('.cart-toggle');
  const overlay = document.querySelector('[data-cart-overlay]');
  const drawer = document.querySelector('.cart-drawer');
  const closeBtn = document.querySelector('.cart-close');
  const open = () => { drawer.classList.add('open'); overlay.classList.add('active'); };
  const close = () => { drawer.classList.remove('open'); overlay.classList.remove('active'); };
  if (toggle) toggle.addEventListener('click', open);
  if (closeBtn) closeBtn.addEventListener('click', close);
  if (overlay) overlay.addEventListener('click', close);
}

function initCheckout() {
  const form = document.querySelector('.checkout-form');
  if (!form) return;
  form.addEventListener('submit', e => {
    e.preventDefault();
    if (cart.length === 0) return alert('Adicione itens ao carrinho antes de finalizar.');
    const name = form.name.value.trim();
    const phone = form.phone.value.trim();
    const payment = form.payment.value;
    const items = cart.map(i => `- ${i.name} (x${i.qty}) – R$ ${(i.price * i.qty).toFixed(2)}`).join('\n');
    const total = cart.reduce((s, i) => s + i.price * i.qty, 0).toFixed(2);
    const message = encodeURIComponent(`Olá, gostaria de finalizar o pedido:\n${items}\n\nTotal: R$ ${total}\nNome: ${name}\nWhatsApp: ${phone}\nPagamento: ${payment}`);
    const waLink = `https://wa.me/5551989896518?text=${message}`;
    window.open(waLink, '_blank');
  });
}

window.addEventListener('DOMContentLoaded', () => {
  initAddToCartButtons();
  initCartDrawer();
  initCheckout();
  updateCartCount();
  renderCartItems();
});
