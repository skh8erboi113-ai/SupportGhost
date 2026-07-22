export function buildSupportPrompt(storeName: string, ticketBody: string, order: any) {
  return `You are support for ${storeName}. Customer: ${ticketBody}. Order: ${order?.shopify_order_id} Status: ${order?.status} Tracking: ${order?.tracking}. Draft 3 sentence helpful reply with tracking link.`;
}
