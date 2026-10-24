// Force-included before every translation unit. Bridges Metrowerks-isms to GCC.
#pragma once
#ifdef __cplusplus
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <cmath>
#endif
#define __declspec(x)
#define __attribute_unused __attribute__((unused))
