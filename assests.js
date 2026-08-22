// Dayflow HRMS - Static Asset Registry
// Central place for every image/icon path used across the app.
// Grouped by feature area so new modules can extend a single object
// instead of a flat, hard-to-scan list.

const ASSET_BASE_PATH = "/assets";

const brand = {
  logo: `${ASSET_BASE_PATH}/logo.png`,
  logoDark: `${ASSET_BASE_PATH}/logo-dark.png`,
  favicon: `${ASSET_BASE_PATH}/favicon.ico`,
};

const navigationIcons = {
  dashboard: `${ASSET_BASE_PATH}/icons/dashboard.svg`,
  employees: `${ASSET_BASE_PATH}/icons/employees.svg`,
  attendance: `${ASSET_BASE_PATH}/icons/attendance.svg`,
  leave: `${ASSET_BASE_PATH}/icons/leave.svg`,
  payroll: `${ASSET_BASE_PATH}/icons/payroll.svg`,
  documents: `${ASSET_BASE_PATH}/icons/documents.svg`,
  notifications: `${ASSET_BASE_PATH}/icons/notifications.svg`,
  reports: `${ASSET_BASE_PATH}/icons/reports.svg`,
  profile: `${ASSET_BASE_PATH}/icons/profile.svg`,
  settings: `${ASSET_BASE_PATH}/icons/settings.svg`,
  logout: `${ASSET_BASE_PATH}/icons/logout.svg`,
};

const statusIcons = {
  present: `${ASSET_BASE_PATH}/icons/status/present.svg`,
  absent: `${ASSET_BASE_PATH}/icons/status/absent.svg`,
  halfDay: `${ASSET_BASE_PATH}/icons/status/half-day.svg`,
  onLeave: `${ASSET_BASE_PATH}/icons/status/on-leave.svg`,
  pending: `${ASSET_BASE_PATH}/icons/status/pending.svg`,
  approved: `${ASSET_BASE_PATH}/icons/status/approved.svg`,
  rejected: `${ASSET_BASE_PATH}/icons/status/rejected.svg`,
};

const illustrations = {
  defaultProfile: `${ASSET_BASE_PATH}/images/default-profile.png`,
  emptyState: `${ASSET_BASE_PATH}/images/empty-state.png`,
  loginBackground: `${ASSET_BASE_PATH}/images/login-bg.png`,
  errorState: `${ASSET_BASE_PATH}/images/error-state.png`,
};

const assets = {
  brand,
  navigationIcons,
  statusIcons,
  illustrations,
};

export default assets;

// Named exports for callers that only need one group,
// e.g. import { navigationIcons } from "constants/assets";
export { brand, navigationIcons, statusIcons, illustrations };