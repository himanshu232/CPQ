trigger CXUpdateOnLeadConversion on Lead (after update) {
  new CXLeadConversionTriggerHandler().run();
}