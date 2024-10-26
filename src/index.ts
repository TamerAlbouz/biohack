import * as logger from "firebase-functions/logger";
import { onMessagePublished } from "firebase-functions/v2/pubsub";
import {
  _maybeDisableBilling,
  BillingNotificationData,
} from "./models/billing";
import { initializeApp } from "firebase-admin/app";

initializeApp();

exports.handleBillingAlert = onMessagePublished(
  "projects/medtalk-aefa8/topics/billing",
  async (event) => {
    logger.debug("Billing alert received");
    const message: BillingNotificationData = event.data.message.json;
    logger.debug(`Billing data received: ${JSON.stringify(message)}`);

    const budgetExceeded = message.costAmount >= message.budgetAmount;

    if (budgetExceeded) {
      logger.info(
        `Budget exceeded for ${message.budgetDisplayName}! 
        Cost: ${message.costAmount} ${message.currencyCode}, 
        Budget: ${message.budgetAmount} ${message.currencyCode}`
      );
      _maybeDisableBilling();
    }
  }
);
