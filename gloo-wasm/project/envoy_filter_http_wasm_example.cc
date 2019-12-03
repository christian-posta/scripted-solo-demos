// NOLINT(namespace-envoy)
#include <string>
#include <unordered_map>

#include "proxy_wasm_intrinsics.h"

class ExampleRootContext : public RootContext {
public:
  explicit ExampleRootContext(uint32_t id, StringView root_id) : RootContext(id, root_id) {}
};

class ExampleContext : public Context {
public:
  explicit ExampleContext(uint32_t id, RootContext* root) : Context(id, root), root_(static_cast<ExampleRootContext*>(static_cast<void*>(root))) {}

  FilterHeadersStatus onResponseHeaders(uint32_t headers) override;
  ExampleRootContext* root_;
};

static RegisterContextFactory register_ExampleContext(CONTEXT_FACTORY(ExampleContext),
                                                      ROOT_FACTORY(ExampleRootContext),
                                                      "my_root_id");
FilterHeadersStatus ExampleContext::onResponseHeaders(uint32_t headers){
    addResponseHeader("kubecon", "ceposta");
    return FilterHeadersStatus::Continue;
}