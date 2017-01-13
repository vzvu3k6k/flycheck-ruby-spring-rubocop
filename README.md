# flycheck-spring-rubocop.el

This is a flycheck extension to run rubocop via spring binstub.

## Setup

It is recommended to use the following configuration.

```lisp
;; Disable ruby-spring-rubocop checker by default.
(setq-default flycheck-disabled-checkers '(ruby-spring-rubocop))

;; Enable ruby-spring-rubocop and disable ruby-rubocop buffer-locally
;; if spring binstub of rubocop is available.
(add-hook ruby-mode-hook #'flycheck-ruby-spring-rubocop-init)
```

## Links

- [toptal/spring-commands-rubocop: RuboCop command for Spring](https://github.com/toptal/spring-commands-rubocop)
