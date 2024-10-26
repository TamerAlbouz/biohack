import { CloudBillingClient } from "@google-cloud/billing";
import * as logger from "firebase-functions/logger";

export type BillingNotificationData = {
  budgetDisplayName: string;
  alertThresholdExceeded?: number;
  costAmount: number;
  costIntervalStart: string;
  budgetAmount: number;
  budgetAmountType:
    | "SPECIFIED_AMOUNT"
    | "LAST_MONTH_COST"
    | "LAST_PERIODS_COST";
  currencyCode: string;
  forcastThresholdExceeded?: number;
};

const PROJECT_ID = process.env.GCLOUD_PROJECT;
const PROJECT_NAME = `projects/${PROJECT_ID}`;
const billing = new CloudBillingClient();

/**
 * Determine whether billing is enabled
 * @return {bool} Whether project has billing enabled or not
 */
const _isBillingEnabled = async () => {
  try {
    const [res] = await billing.getProjectBillingInfo({ name: PROJECT_NAME });
    logger.debug(`Billing enabled: ${JSON.stringify(res)}`);
    return res.billingEnabled;
  } catch (e) {
    logger.debug(
      `Unable to determine if billing is enabled 
      on specified project, assuming billing is enabled`
    );
    return true;
  }
};

/**
 * Disable billing for project by removing its billing account
 * @return {string} Text containing response from disabling billing
 */
export const _maybeDisableBilling = async () => {
  const billingEnabled = await _isBillingEnabled();
  if (!billingEnabled) {
    logger.error("Billing is already disabled");
    return;
  }
  try {
    const [res] = await billing.updateProjectBillingInfo({
      name: PROJECT_NAME,
      projectBillingInfo: { billingAccountName: "" }, // Disable billing
    });
    logger.debug(`Billing disabled: ${JSON.stringify(res)}`);
  } catch (e) {
    logger.error(`Error disabling billing: ${e}`);
  }
};
