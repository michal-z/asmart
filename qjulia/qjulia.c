//-----------------------------------------------------------------------------
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#include <immintrin.h>
//-----------------------------------------------------------------------------
extern __declspec(selectany) __m256d k_0_1;
extern __declspec(selectany) __m256d k_0_25;
extern __declspec(selectany) __m256d k_0_5;
extern __declspec(selectany) __m256d k_1_0;
extern __declspec(selectany) __m256d k_4_0;
extern __declspec(selectany) __m256d k_m1_0;
extern __declspec(selectany) __m256d k_1023_0;
extern __declspec(selectany) __m256 k_1_0f;
extern __declspec(selectany) __m256i k_000fffffffffffff;
extern __declspec(selectany) __m256i k_3fe0000000000000;
extern __declspec(selectany) __m256d k_half_sqrt2;
#define k_0_0 _mm256_setzero_pd()
#define k_0_0f _mm256_setzero_ps()
extern __declspec(selectany) __m256d k_2pow52_0;
extern __declspec(selectany) __m256d k_hit_distance;
extern __declspec(selectany) __m256d k_view_distance;
extern __declspec(selectany) __m256d k_escape_threshold;
extern __declspec(selectany) __m256d k_normal_epsilon;
extern __declspec(selectany) __m256d k_ln2_hi;
extern __declspec(selectany) __m256d k_ln2_lo;
extern __declspec(selectany) __m256d k_log_p0;
extern __declspec(selectany) __m256d k_log_p1;
extern __declspec(selectany) __m256d k_log_p2;
extern __declspec(selectany) __m256d k_log_p3;
extern __declspec(selectany) __m256d k_log_p4;
extern __declspec(selectany) __m256d k_log_p5;
extern __declspec(selectany) __m256d k_log_q0;
extern __declspec(selectany) __m256d k_log_q1;
extern __declspec(selectany) __m256d k_log_q2;
extern __declspec(selectany) __m256d k_log_q3;
extern __declspec(selectany) __m256d k_log_q4;
//-----------------------------------------------------------------------------
#define k_resolutionx (1024)
#define k_resolutiony (1024)
#define k_pixel_size_in_bytes (4*sizeof(float))
#define k_tile_size 64
#define k_tile_size_in_bytes (k_tile_size*k_tile_size*k_pixel_size_in_bytes)
#define k_tile_countx (k_resolutionx / k_tile_size)
#define k_tile_county (k_resolutiony / k_tile_size)
#define k_tile_count (k_tile_countx * k_tile_county)
#define k_thread_max_count 16
#define k_sample_count 1024
//-----------------------------------------------------------------------------
typedef __declspec(align(32)) struct {
  __m256d x, y;
} v2__m256d;

typedef __declspec(align(32)) struct {
  __m256d x, y, z;
} v3__m256d;

typedef __declspec(align(32)) struct {
  __m256d x, y, z, w;
} v4__m256d;

typedef __declspec(align(32)) struct {
  __m256 x, y, z;
} v3__m256;

typedef __declspec(align(32)) struct {
  __m128i x, y, z;
} v3__m128i;

typedef __declspec(align(32)) struct {
  __m256i x, y, z;
} v3__m256i;

static __forceinline v2__m256d __vectorcall
v2__m256d_set(__m256d x, __m256d y)
{
  v2__m256d r;
  r.x = x;
  r.y = y;
  return r;
}
static v2__m256d
v2__m256d_rand_zero_one(void)
{
  __declspec(align(32)) double rnd[8];
  for (int i = 0; i < 8; ++i) {
    unsigned long long r;
    while (_rdrand64_step(&r) == 0);
    rnd[i] = (double)r / MAXUINT64;
  }

  v2__m256d r;
  r.x = _mm256_load_pd(&rnd[0]);
  r.y = _mm256_load_pd(&rnd[4]);
  return r;
}

static __forceinline v3__m256d __vectorcall
v3__m256d_set(__m256d x, __m256d y, __m256d z)
{
  v3__m256d r;
  r.x = x;
  r.y = y;
  r.z = z;
  return r;
}
static __forceinline v3__m256d __vectorcall
v3__m256d_add(v3__m256d v0, v3__m256d v1)
{
  v3__m256d r;
  r.x = _mm256_add_pd(v0.x, v1.x);
  r.y = _mm256_add_pd(v0.y, v1.y);
  r.z = _mm256_add_pd(v0.z, v1.z);
  return r;
}
static __forceinline v3__m256d __vectorcall
v3__m256d_sub(v3__m256d v0, v3__m256d v1)
{
  v3__m256d r;
  r.x = _mm256_sub_pd(v0.x, v1.x);
  r.y = _mm256_sub_pd(v0.y, v1.y);
  r.z = _mm256_sub_pd(v0.z, v1.z);
  return r;
}
static __forceinline __m256d __vectorcall
v3__m256d_length(v3__m256d v)
{
  __m256d len = _mm256_mul_pd(v.x, v.x);
  len = _mm256_fmadd_pd(v.y, v.y, len);
  len = _mm256_fmadd_pd(v.z, v.z, len);
  return _mm256_sqrt_pd(len);
}
static __forceinline v3__m256d __vectorcall
v3__m256d_normalize(v3__m256d v)
{
  __m256d rcplen = _mm256_mul_pd(v.x, v.x);
  rcplen = _mm256_fmadd_pd(v.y, v.y, rcplen);
  rcplen = _mm256_fmadd_pd(v.z, v.z, rcplen);
  rcplen = _mm256_sqrt_pd(rcplen);
  rcplen = _mm256_div_pd(k_1_0, rcplen);

  v3__m256d r;
  r.x = _mm256_mul_pd(v.x, rcplen);
  r.y = _mm256_mul_pd(v.y, rcplen);
  r.z = _mm256_mul_pd(v.z, rcplen);
  return r;
}
static __forceinline v3__m256d __vectorcall
v3__m256d_cross(v3__m256d v0, v3__m256d v1)
{
  v3__m256d r;
  __m256d v0z_v1y = _mm256_mul_pd(v0.z, v1.y);
  __m256d v0x_v1z = _mm256_mul_pd(v0.x, v1.z);
  __m256d v0y_v1x = _mm256_mul_pd(v0.y, v1.x);
  r.x = _mm256_fmsub_pd(v0.y, v1.z, v0z_v1y);
  r.y = _mm256_fmsub_pd(v0.z, v1.x, v0x_v1z);
  r.z = _mm256_fmsub_pd(v0.x, v1.y, v0y_v1x);
  return r;
}
static __forceinline v3__m256d __vectorcall
v3__m256d_broadcast(const double *x, const double *y, const double *z)
{
  v3__m256d r;
  r.x = _mm256_broadcast_sd(x);
  r.y = _mm256_broadcast_sd(y);
  r.z = _mm256_broadcast_sd(z);
  return r;
}
static __forceinline __m256d __vectorcall
v3__m256d_dot(v3__m256d v0, v3__m256d v1)
{
  __m256d dot = _mm256_mul_pd(v0.x, v1.x);
  dot = _mm256_fmadd_pd(v0.y, v1.y, dot);
  return _mm256_fmadd_pd(v0.z, v1.z, dot);
}
static __forceinline v3__m256d __vectorcall
v3__m256d_blendv1(v3__m256d v0, v3__m256d v1, __m256d mask)
{
  v3__m256d r;
  r.x = _mm256_blendv_pd(v0.x, v1.x, mask);
  r.y = _mm256_blendv_pd(v0.y, v1.y, mask);
  r.z = _mm256_blendv_pd(v0.z, v1.z, mask);
  return r;
}

static __forceinline v4__m256d __vectorcall
v4__m256d_set(__m256d x, __m256d y, __m256d z, __m256d w)
{
  v4__m256d r;
  r.x = x;
  r.y = y;
  r.z = z;
  r.w = w;
  return r;
}
static __forceinline v4__m256d
v4__m256d_qmul(v4__m256d q0, v4__m256d q1)
{
  v4__m256d r;
  r.w = _mm256_mul_pd(q0.w, q1.w);
  r.w = _mm256_fnmadd_pd(q0.x, q1.x, r.w);
  r.w = _mm256_fnmadd_pd(q0.y, q1.y, r.w);
  r.w = _mm256_fnmadd_pd(q0.z, q1.z, r.w);
  r.x = _mm256_mul_pd(q0.w, q1.x);
  r.x = _mm256_fmadd_pd(q0.x, q1.w, r.x);
  r.x = _mm256_fmadd_pd(q0.y, q1.z, r.x);
  r.x = _mm256_fnmadd_pd(q0.z, q1.y, r.x);
  r.y = _mm256_mul_pd(q0.w, q1.y);
  r.y = _mm256_fnmadd_pd(q0.x, q1.z, r.y);
  r.y = _mm256_fmadd_pd(q0.y, q1.w, r.y);
  r.y = _mm256_fmadd_pd(q0.z, q1.x, r.y);
  r.z = _mm256_mul_pd(q0.w, q1.z);
  r.z = _mm256_fmadd_pd(q0.x, q1.y, r.z);
  r.z = _mm256_fnmadd_pd(q0.y, q1.x, r.z);
  r.z = _mm256_fmadd_pd(q0.z, q1.w, r.z);
  return r;
}
static __forceinline v4__m256d
v4__m256d_qsq(v4__m256d q)
{
  v4__m256d r;
  r.w = _mm256_mul_pd(q.w, q.w);
  r.w = _mm256_fnmadd_pd(q.x, q.x, r.w);
  r.w = _mm256_fnmadd_pd(q.y, q.y, r.w);
  r.w = _mm256_fnmadd_pd(q.z, q.z, r.w);
  r.x = _mm256_mul_pd(q.x, q.w);
  r.y = _mm256_mul_pd(q.y, q.w);
  r.z = _mm256_mul_pd(q.z, q.w);
  r.x = _mm256_add_pd(r.x, r.x);
  r.y = _mm256_add_pd(r.y, r.y);
  r.z = _mm256_add_pd(r.z, r.z);
  return r;
}
static __forceinline __m256d
v4__m256d_dot(v4__m256d v0, v4__m256d v1)
{
  __m256d r = _mm256_mul_pd(v0.w, v1.w);
  r = _mm256_fmadd_pd(v0.x, v1.x, r);
  r = _mm256_fmadd_pd(v0.y, v1.y, r);
  return _mm256_fmadd_pd(v0.z, v1.z, r);
}
static __forceinline v4__m256d
v4__m256d_add(v4__m256d v0, v4__m256d v1)
{
  v4__m256d r;
  r.x = _mm256_add_pd(v0.x, v1.x);
  r.y = _mm256_add_pd(v0.y, v1.y);
  r.z = _mm256_add_pd(v0.z, v1.z);
  r.w = _mm256_add_pd(v0.w, v1.w);
  return r;
}
static __forceinline __m256d __vectorcall
v4__m256d_length(v4__m256d v)
{
  __m256d len = _mm256_mul_pd(v.x, v.x);
  len = _mm256_fmadd_pd(v.y, v.y, len);
  len = _mm256_fmadd_pd(v.z, v.z, len);
  len = _mm256_fmadd_pd(v.w, v.w, len);
  return _mm256_sqrt_pd(len);
}
static __forceinline v4__m256d __vectorcall
v4__m256d_blendv1(v4__m256d v0, v4__m256d v1, __m256d mask)
{
  v4__m256d r;
  r.x = _mm256_blendv_pd(v0.x, v1.x, mask);
  r.y = _mm256_blendv_pd(v0.y, v1.y, mask);
  r.z = _mm256_blendv_pd(v0.z, v1.z, mask);
  r.w = _mm256_blendv_pd(v0.w, v1.w, mask);
  return r;
}

static __inline __m256d
s__m256d_log(__m256d x)
{
  __m256i xi = _mm256_castpd_si256(x);
  __m256d xf = _mm256_castsi256_pd(_mm256_or_si256(_mm256_and_si256(xi, k_000fffffffffffff),
                                                   k_3fe0000000000000));

  __m256d xe = _mm256_castsi256_pd(_mm256_or_si256(_mm256_srli_epi64(xi, 52),
                                                   _mm256_castpd_si256(k_2pow52_0)));
  xe = _mm256_sub_pd(xe, _mm256_add_pd(k_2pow52_0, k_1023_0));

  __m256d mask = _mm256_cmp_pd(xf, k_half_sqrt2, _CMP_GT_OS);
  xf = _mm256_add_pd(xf, _mm256_andnot_pd(mask, xf));
  xf = _mm256_sub_pd(xf, k_1_0);

  xe = _mm256_add_pd(xe, _mm256_and_pd(mask, k_1_0));

  __m256d x2 = _mm256_mul_pd(xf, xf);
  __m256d x3 = _mm256_mul_pd(x2, xf);
  __m256d x4 = _mm256_mul_pd(x2, x2);

  __m256d p1x_p0 = _mm256_fmadd_pd(k_log_p1, xf, k_log_p0);
  __m256d p3x_p2 = _mm256_fmadd_pd(k_log_p3, xf, k_log_p2);
  __m256d p5x_p4 = _mm256_fmadd_pd(k_log_p5, xf, k_log_p4);
  __m256d px = _mm256_fmadd_pd(p3x_p2, x2, _mm256_fmadd_pd(p5x_p4, x4, p1x_p0));
  px = _mm256_mul_pd(px, x3);

  __m256d q1x_q0 = _mm256_fmadd_pd(k_log_q1, xf, k_log_q0);
  __m256d q3x_q2 = _mm256_fmadd_pd(k_log_q3, xf, k_log_q2);
  __m256d q4_x = _mm256_add_pd(k_log_q4, xf);
  __m256d qx = _mm256_fmadd_pd(q3x_q2, x2, _mm256_fmadd_pd(q4_x, x4, q1x_q0));

  __m256d res = _mm256_div_pd(px, qx);
  res = _mm256_fmadd_pd(xe, k_ln2_lo, res);
  res = _mm256_add_pd(res, xf);
  res = _mm256_fnmadd_pd(k_0_5, x2, res);
  res = _mm256_fmadd_pd(xe, k_ln2_hi, res);

  return res;
}

typedef struct qjulia qjulia_t;

typedef struct worker_thread {
  HANDLE thread_handle;
  HANDLE semaphore_handle;
  qjulia_t *qj;
  int tid;
} worker_thread_t;

typedef struct qjulia {
  const char *name;
  double time, prev_time, prev_fps_time;
  float time_delta;
  HWND hwnd;
  HDC hdc, mdc;
  HBITMAP hbm;
  HANDLE heap;
  int fps_counter;
  LARGE_INTEGER frequency, start_counter;
  unsigned char *displayptr;
  unsigned char *image_state;
  int tileidx;
  int sample_count;
  int worker_thread_count;
  worker_thread_t thread[k_thread_max_count];
  HANDLE main_thread_sem;
  double eye_position[3], eye_focus[3];
  double xaxis[3], yaxis[3], zaxis[3];
  double light_position[2][3];
} qjulia_t;
//-----------------------------------------------------------------------------
int _fltused = 0x9875;
extern __declspec(selectany) v4__m256d k_quat;
//-----------------------------------------------------------------------------
static LRESULT CALLBACK
winproc(HWND win, UINT msg, WPARAM wparam, LPARAM lparam)
{
  switch (msg) {
  case WM_DESTROY:
  case WM_KEYDOWN:
    PostQuitMessage(0);
    return 0;
  }
  return DefWindowProc(win, msg, wparam, lparam);
}
//-----------------------------------------------------------------------------
static double
get_time(qjulia_t *me)
{
  LARGE_INTEGER counter;
  QueryPerformanceCounter(&counter);
  return (counter.QuadPart - me->start_counter.QuadPart) / (double)me->frequency.QuadPart;
}
//-----------------------------------------------------------------------------
static void
update_time_stats(qjulia_t *me)
{
  me->time = get_time(me);
  me->time_delta = (float)(me->time - me->prev_time);
  me->prev_time = me->time;

  if ((me->time - me->prev_fps_time) >= 1.0) {
    double fps = me->fps_counter / (me->time - me->prev_fps_time);
    double ms = (1.0 / fps) * 1000.0;
    char text[256];
    wsprintf(text, "[%d samples | %d ms/sample] %s", (int)me->sample_count, (int)ms, me->name);
    SetWindowText(me->hwnd, text);
    me->prev_fps_time = me->time;
    me->fps_counter = 0;
  }
  me->fps_counter++;
}
//-----------------------------------------------------------------------------
static v2__m256d __vectorcall
geometry_distance(v3__m256d p0, v3__m256d p1)
{
  v2__m256d dist = v2__m256d_set(_mm256_add_pd(p0.y, k_1_0), _mm256_add_pd(p1.y, k_1_0));
  return dist;
}
//-----------------------------------------------------------------------------
static v2__m256d __vectorcall
qjulia_distance(v3__m256d p0, v3__m256d p1)
{
  v4__m256d q[2], qp[2];
  q[0] = v4__m256d_set(p0.y, p0.z, k_0_0, p0.x);
  q[1] = v4__m256d_set(p1.y, p1.z, k_0_0, p1.x);
  qp[0] = v4__m256d_set(k_0_0, k_0_0, k_0_0, k_1_0);
  qp[1] = v4__m256d_set(k_0_0, k_0_0, k_0_0, k_1_0);

  for (int i = 0; i < 16; ++i) {
    v4__m256d next_q[2], next_qp[2];
    next_qp[0] = v4__m256d_qmul(q[0], qp[0]);
    next_qp[1] = v4__m256d_qmul(q[1], qp[1]);
    next_qp[0] = v4__m256d_add(next_qp[0], next_qp[0]);
    next_qp[1] = v4__m256d_add(next_qp[1], next_qp[1]);

    next_q[0] = v4__m256d_qsq(q[0]);
    next_q[0] = v4__m256d_add(next_q[0], k_quat);
    next_q[1] = v4__m256d_qsq(q[1]);
    next_q[1] = v4__m256d_add(next_q[1], k_quat);

    __m256d dot[2];
    dot[0] = v4__m256d_dot(next_q[0], next_q[0]);
    dot[1] = v4__m256d_dot(next_q[1], next_q[1]);

    __m256d mask[2];
    mask[0] = _mm256_cmp_pd(dot[0], k_escape_threshold, _CMP_GT_OS);
    mask[1] = _mm256_cmp_pd(dot[1], k_escape_threshold, _CMP_GT_OS);

    q[0] = v4__m256d_blendv1(next_q[0], q[0], mask[0]);
    q[1] = v4__m256d_blendv1(next_q[1], q[1], mask[1]);
    qp[0] = v4__m256d_blendv1(next_qp[0], qp[0], mask[0]);
    qp[1] = v4__m256d_blendv1(next_qp[1], qp[1], mask[1]);

    if (_mm256_movemask_pd(mask[0]) == 0x0f && _mm256_movemask_pd(mask[1]) == 0x0f) break;
  }

  __m256d mq[2];
  mq[0] = v4__m256d_length(q[0]);
  mq[1] = v4__m256d_length(q[1]);

  v2__m256d dist;
  dist.x = _mm256_mul_pd(k_0_5, mq[0]);
  dist.x = _mm256_mul_pd(dist.x, s__m256d_log(mq[0]));
  dist.x = _mm256_div_pd(dist.x, v4__m256d_length(qp[0]));

  dist.y = _mm256_mul_pd(k_0_5, mq[1]);
  dist.y = _mm256_mul_pd(dist.y, s__m256d_log(mq[1]));
  dist.y = _mm256_div_pd(dist.y, v4__m256d_length(qp[1]));

  return dist;
}
//-----------------------------------------------------------------------------
static v2__m256d __vectorcall
nearest_distance(v3__m256d p0, v3__m256d p1, __m256d *qmask0, __m256d *qmask1)
{
  v2__m256d dg = geometry_distance(p0, p1);
  v2__m256d dq = qjulia_distance(p0, p1);
  *qmask0 = _mm256_cmp_pd(dq.x, dg.x, _CMP_LE_OS);
  *qmask1 = _mm256_cmp_pd(dq.y, dg.y, _CMP_LE_OS);
  v2__m256d d;
  d.x = _mm256_min_pd(dq.x, dg.x);
  d.y = _mm256_min_pd(dq.y, dg.y);
  return d;
}
//-----------------------------------------------------------------------------
static v2__m256d __vectorcall
cast_ray(v3__m256d rayo0, v3__m256d rayo1, v3__m256d rayd0, v3__m256d rayd1,
         v3__m256d *pos0, v3__m256d *pos1, __m256d *qmask0, __m256d *qmask1)
{
  v2__m256d distance = v2__m256d_set(k_1_0, k_1_0);

  for (int i = 0; i < 1024; ++i) {
    pos0->x = _mm256_fmadd_pd(rayd0.x, distance.x, rayo0.x);
    pos0->y = _mm256_fmadd_pd(rayd0.y, distance.x, rayo0.y);
    pos0->z = _mm256_fmadd_pd(rayd0.z, distance.x, rayo0.z);
    pos1->x = _mm256_fmadd_pd(rayd1.x, distance.y, rayo1.x);
    pos1->y = _mm256_fmadd_pd(rayd1.y, distance.y, rayo1.y);
    pos1->z = _mm256_fmadd_pd(rayd1.z, distance.y, rayo1.z);

    v2__m256d dist = nearest_distance(*pos0, *pos1, qmask0, qmask1);

    v2__m256d msk0;
    msk0.x = _mm256_cmp_pd(dist.x, k_hit_distance, _CMP_LE_OS);
    msk0.y = _mm256_cmp_pd(dist.y, k_hit_distance, _CMP_LE_OS);

    v2__m256d msk1;
    msk1.x = _mm256_cmp_pd(distance.x, k_view_distance, _CMP_GE_OS);
    msk1.y = _mm256_cmp_pd(distance.y, k_view_distance, _CMP_GE_OS);

    v2__m256d done_msk;
    done_msk.x = _mm256_or_pd(msk0.x, msk1.x);
    done_msk.y = _mm256_or_pd(msk0.y, msk1.y);

    if (_mm256_movemask_pd(done_msk.x) == 0x0f && _mm256_movemask_pd(done_msk.y) == 0x0f) break;

    dist.x = _mm256_andnot_pd(done_msk.x, dist.x);
    dist.y = _mm256_andnot_pd(done_msk.y, dist.y);

    distance.x = _mm256_add_pd(distance.x, dist.x);
    distance.y = _mm256_add_pd(distance.y, dist.y);
  }
  return distance;
}
//-----------------------------------------------------------------------------
static void __vectorcall
geometry_normal(v3__m256d p0, v3__m256d p1, v3__m256d *n0, v3__m256d *n1)
{
  v3__m256d posx[2], negx[2];
  v3__m256d posy[2], negy[2];
  v3__m256d posz[2], negz[2];

  posx[0] = v3__m256d_set(_mm256_add_pd(p0.x, k_normal_epsilon), p0.y, p0.z);
  negx[0] = v3__m256d_set(_mm256_sub_pd(p0.x, k_normal_epsilon), p0.y, p0.z);
  posy[0] = v3__m256d_set(p0.x, _mm256_add_pd(p0.y, k_normal_epsilon), p0.z);
  negy[0] = v3__m256d_set(p0.x, _mm256_sub_pd(p0.y, k_normal_epsilon), p0.z);
  posz[0] = v3__m256d_set(p0.x, p0.y, _mm256_add_pd(p0.z, k_normal_epsilon));
  negz[0] = v3__m256d_set(p0.x, p0.y, _mm256_sub_pd(p0.z, k_normal_epsilon));

  posx[1] = v3__m256d_set(_mm256_add_pd(p1.x, k_normal_epsilon), p1.y, p1.z);
  negx[1] = v3__m256d_set(_mm256_sub_pd(p1.x, k_normal_epsilon), p1.y, p1.z);
  posy[1] = v3__m256d_set(p1.x, _mm256_add_pd(p1.y, k_normal_epsilon), p1.z);
  negy[1] = v3__m256d_set(p1.x, _mm256_sub_pd(p1.y, k_normal_epsilon), p1.z);
  posz[1] = v3__m256d_set(p1.x, p1.y, _mm256_add_pd(p1.z, k_normal_epsilon));
  negz[1] = v3__m256d_set(p1.x, p1.y, _mm256_sub_pd(p1.z, k_normal_epsilon));

  v2__m256d dposx = geometry_distance(posx[0], posx[1]);
  v2__m256d dnegx = geometry_distance(negx[0], negx[1]);
  v2__m256d dposy = geometry_distance(posy[0], posy[1]);
  v2__m256d dnegy = geometry_distance(negy[0], negy[1]);
  v2__m256d dposz = geometry_distance(posz[0], posz[1]);
  v2__m256d dnegz = geometry_distance(negz[0], negz[1]);

  *n0 = v3__m256d_set(_mm256_sub_pd(dposx.x, dnegx.x), _mm256_sub_pd(dposy.x, dnegy.x), _mm256_sub_pd(dposz.x, dnegz.x));
  *n1 = v3__m256d_set(_mm256_sub_pd(dposx.y, dnegx.y), _mm256_sub_pd(dposy.y, dnegy.y), _mm256_sub_pd(dposz.y, dnegz.y));
  *n0 = v3__m256d_normalize(*n0);
  *n1 = v3__m256d_normalize(*n1);
}
//-----------------------------------------------------------------------------
static void __vectorcall
qjulia_normal(v3__m256d p0, v3__m256d p1, v3__m256d *n0, v3__m256d *n1)
{
  v4__m256d posx[2], negx[2];
  v4__m256d posy[2], negy[2];
  v4__m256d posz[2], negz[2];

  posx[0] = v4__m256d_set(p0.y, p0.z, k_0_0, _mm256_add_pd(p0.x, k_normal_epsilon));
  negx[0] = v4__m256d_set(p0.y, p0.z, k_0_0, _mm256_sub_pd(p0.x, k_normal_epsilon));
  posy[0] = v4__m256d_set(_mm256_add_pd(p0.y, k_normal_epsilon), p0.z, k_0_0, p0.x);
  negy[0] = v4__m256d_set(_mm256_sub_pd(p0.y, k_normal_epsilon), p0.z, k_0_0, p0.x);
  posz[0] = v4__m256d_set(p0.y, _mm256_add_pd(p0.z, k_normal_epsilon), k_0_0, p0.x);
  negz[0] = v4__m256d_set(p0.y, _mm256_sub_pd(p0.z, k_normal_epsilon), k_0_0, p0.x);

  posx[1] = v4__m256d_set(p1.y, p1.z, k_0_0, _mm256_add_pd(p1.x, k_normal_epsilon));
  negx[1] = v4__m256d_set(p1.y, p1.z, k_0_0, _mm256_sub_pd(p1.x, k_normal_epsilon));
  posy[1] = v4__m256d_set(_mm256_add_pd(p1.y, k_normal_epsilon), p1.z, k_0_0, p1.x);
  negy[1] = v4__m256d_set(_mm256_sub_pd(p1.y, k_normal_epsilon), p1.z, k_0_0, p1.x);
  posz[1] = v4__m256d_set(p1.y, _mm256_add_pd(p1.z, k_normal_epsilon), k_0_0, p1.x);
  negz[1] = v4__m256d_set(p1.y, _mm256_sub_pd(p1.z, k_normal_epsilon), k_0_0, p1.x);

  for (int i = 0; i < 16; ++i) {
    posx[0] = v4__m256d_qsq(posx[0]);
    negx[0] = v4__m256d_qsq(negx[0]);
    posy[0] = v4__m256d_qsq(posy[0]);
    negy[0] = v4__m256d_qsq(negy[0]);
    posz[0] = v4__m256d_qsq(posz[0]);
    negz[0] = v4__m256d_qsq(negz[0]);
    posx[0] = v4__m256d_add(posx[0], k_quat);
    negx[0] = v4__m256d_add(negx[0], k_quat);
    posy[0] = v4__m256d_add(posy[0], k_quat);
    negy[0] = v4__m256d_add(negy[0], k_quat);
    posz[0] = v4__m256d_add(posz[0], k_quat);
    negz[0] = v4__m256d_add(negz[0], k_quat);

    posx[1] = v4__m256d_qsq(posx[1]);
    negx[1] = v4__m256d_qsq(negx[1]);
    posy[1] = v4__m256d_qsq(posy[1]);
    negy[1] = v4__m256d_qsq(negy[1]);
    posz[1] = v4__m256d_qsq(posz[1]);
    negz[1] = v4__m256d_qsq(negz[1]);
    posx[1] = v4__m256d_add(posx[1], k_quat);
    negx[1] = v4__m256d_add(negx[1], k_quat);
    posy[1] = v4__m256d_add(posy[1], k_quat);
    negy[1] = v4__m256d_add(negy[1], k_quat);
    posz[1] = v4__m256d_add(posz[1], k_quat);
    negz[1] = v4__m256d_add(negz[1], k_quat);
  }

  // TODO: try to compute length square instead of length
  n0->x = _mm256_sub_pd(v4__m256d_length(posx[0]), v4__m256d_length(negx[0]));
  n0->y = _mm256_sub_pd(v4__m256d_length(posy[0]), v4__m256d_length(negy[0]));
  n0->z = _mm256_sub_pd(v4__m256d_length(posz[0]), v4__m256d_length(negz[0]));

  n1->x = _mm256_sub_pd(v4__m256d_length(posx[1]), v4__m256d_length(negx[1]));
  n1->y = _mm256_sub_pd(v4__m256d_length(posy[1]), v4__m256d_length(negy[1]));
  n1->z = _mm256_sub_pd(v4__m256d_length(posz[1]), v4__m256d_length(negz[1]));

  *n0 = v3__m256d_normalize(*n0);
  *n1 = v3__m256d_normalize(*n1);
}
//-----------------------------------------------------------------------------
static void __vectorcall
compute_color(qjulia_t *me, v3__m256d pos0, v3__m256d pos1, __m256d qmask0, __m256d qmask1,
              v3__m256d *color0, v3__m256d *color1)
{
  *color0 = v3__m256d_set(k_0_1, k_0_1, k_0_1);
  *color1 = v3__m256d_set(k_0_1, k_0_1, k_0_1);

  for (int i = 0; i < 2; ++i) {
    v3__m256d lpos = v3__m256d_broadcast(&me->light_position[i][0],
                                         &me->light_position[i][1],
                                         &me->light_position[i][2]);
    v3__m256d lvec[2];
    lvec[0] = v3__m256d_sub(lpos, pos0);
    lvec[1] = v3__m256d_sub(lpos, pos1);
    lvec[0] = v3__m256d_normalize(lvec[0]);
    lvec[1] = v3__m256d_normalize(lvec[1]);

    // cast shadow ray
    v3__m256d rayo[2];
    rayo[0].x = _mm256_fmadd_pd(lvec[0].x, k_0_25, pos0.x);
    rayo[0].y = _mm256_fmadd_pd(lvec[0].y, k_0_25, pos0.y);
    rayo[0].z = _mm256_fmadd_pd(lvec[0].z, k_0_25, pos0.z);
    rayo[1].x = _mm256_fmadd_pd(lvec[1].x, k_0_25, pos1.x);
    rayo[1].y = _mm256_fmadd_pd(lvec[1].y, k_0_25, pos1.y);
    rayo[1].z = _mm256_fmadd_pd(lvec[1].z, k_0_25, pos1.z);
    v3__m256d p0, p1;
    __m256d q0, q1;
    v2__m256d dist = cast_ray(pos0, pos1, lvec[0], lvec[1], &p0, &p1, &q0, &q1);
    v2__m256d shadow_mask;
    shadow_mask.x = _mm256_cmp_pd(dist.x, k_view_distance, _CMP_LT_OS);
    shadow_mask.y = _mm256_cmp_pd(dist.y, k_view_distance, _CMP_LT_OS);

    v3__m256d qnormal[2], gnormal[2];
    qjulia_normal(pos0, pos1, &qnormal[0], &qnormal[1]);
    geometry_normal(pos0, pos1, &gnormal[0], &gnormal[1]);

    v3__m256d normal[2];
    normal[0] = v3__m256d_blendv1(gnormal[0], qnormal[0], qmask0);
    normal[1] = v3__m256d_blendv1(gnormal[1], qnormal[1], qmask1);

    __m256d ldotn[2];
    ldotn[0] = v3__m256d_dot(normal[0], lvec[0]);
    ldotn[1] = v3__m256d_dot(normal[1], lvec[1]);

    ldotn[0] = _mm256_andnot_pd(shadow_mask.x, ldotn[0]);
    ldotn[1] = _mm256_andnot_pd(shadow_mask.y, ldotn[1]);

    ldotn[0] = _mm256_max_pd(ldotn[0], k_0_0);
    ldotn[1] = _mm256_max_pd(ldotn[1], k_0_0);
    ldotn[0] = _mm256_mul_pd(ldotn[0], k_0_5);
    ldotn[1] = _mm256_mul_pd(ldotn[1], k_0_5);

    *color0 = v3__m256d_add(v3__m256d_set(ldotn[0], ldotn[0], ldotn[0]), *color0);
    *color1 = v3__m256d_add(v3__m256d_set(ldotn[1], ldotn[1], ldotn[1]), *color1);
  }
}
//-----------------------------------------------------------------------------
static void
generate_fractal(qjulia_t *me)
{
  v3__m256d xxx, yyy, zzz;
  xxx = v3__m256d_broadcast(&me->xaxis[0], &me->yaxis[0], &me->zaxis[0]);
  yyy = v3__m256d_broadcast(&me->xaxis[1], &me->yaxis[1], &me->zaxis[1]);
  zzz = v3__m256d_broadcast(&me->xaxis[2], &me->yaxis[2], &me->zaxis[2]);

  v3__m256d rayo0, rayo1;
  rayo0 = v3__m256d_broadcast(&me->eye_position[0], &me->eye_position[1], &me->eye_position[2]);
  rayo1 = rayo0;

  for (;;) {
    const int tileidx = (int)InterlockedIncrement((LONG *)&me->tileidx) - 1;
    if (tileidx >= k_tile_count) break;

    int tilex[2], tiley[2];
    tilex[0] = (tileidx % k_tile_countx) * k_tile_size;
    tiley[0] = (tileidx / k_tile_countx) * k_tile_size;
    tilex[1] = tilex[0] + k_tile_size;
    tiley[1] = tiley[0] + k_tile_size;

    int offset = tileidx * k_tile_size_in_bytes;
    for (int y = tiley[0]; y < tiley[1]; y += 2) {
      for (int x = tilex[0]; x < tilex[1]; x += 4) {

        v3__m256 dest_color;
        dest_color.x = _mm256_load_ps((const float *)(me->image_state + offset));
        dest_color.y = _mm256_load_ps((const float *)(me->image_state + offset + 32));
        dest_color.z = _mm256_load_ps((const float *)(me->image_state + offset + 64));

        v2__m256d ro[2];
        ro[0] = v2__m256d_rand_zero_one();
        ro[1] = v2__m256d_rand_zero_one();

        v3__m256d pv[2];
        pv[0].x = _mm256_broadcastsd_pd(_mm_cvtsi32_sd(_mm_setzero_pd(), x - k_resolutionx / 2));
        pv[0].y = _mm256_broadcastsd_pd(_mm_cvtsi32_sd(_mm_setzero_pd(), y - k_resolutiony / 2));
        pv[0].z = _mm256_set1_pd(-1.5);
        pv[0].x = _mm256_add_pd(pv[0].x, _mm256_set_pd(3.0, 2.0, 1.0, 0.0));

        pv[1] = pv[0];
        pv[1].y = _mm256_add_pd(pv[1].y, k_1_0);

        pv[0].x = _mm256_add_pd(pv[0].x, ro[0].x);
        pv[0].y = _mm256_add_pd(pv[0].y, ro[0].y);
        pv[1].x = _mm256_add_pd(pv[1].x, ro[1].x);
        pv[1].y = _mm256_add_pd(pv[1].y, ro[1].y);

        __m256d rcpresx = _mm256_set1_pd(2.0 / k_resolutionx);
        __m256d rcpresy = _mm256_set1_pd(2.0 / k_resolutiony);

        pv[0].x = _mm256_mul_pd(pv[0].x, rcpresx);
        pv[0].y = _mm256_mul_pd(pv[0].y, rcpresy);
        pv[1].x = _mm256_mul_pd(pv[1].x, rcpresx);
        pv[1].y = _mm256_mul_pd(pv[1].y, rcpresy);

        v3__m256d rayd0;
        rayd0.x = v3__m256d_dot(pv[0], xxx);
        rayd0.y = v3__m256d_dot(pv[0], yyy);
        rayd0.z = v3__m256d_dot(pv[0], zzz);
        rayd0 = v3__m256d_normalize(rayd0);

        v3__m256d rayd1;
        rayd1.x = v3__m256d_dot(pv[1], xxx);
        rayd1.y = v3__m256d_dot(pv[1], yyy);
        rayd1.z = v3__m256d_dot(pv[1], zzz);
        rayd1 = v3__m256d_normalize(rayd1);

        v3__m256d pos0, pos1;
        __m256d qmask0, qmask1;
        v2__m256d dist = cast_ray(rayo0, rayo1, rayd0, rayd1, &pos0, &pos1, &qmask0, &qmask1);
        v2__m256d dist_hit_msk;
        dist_hit_msk.x = _mm256_cmp_pd(dist.x, k_view_distance, _CMP_LT_OS);
        dist_hit_msk.y = _mm256_cmp_pd(dist.y, k_view_distance, _CMP_LT_OS);

        //v2__m256d rcpdist;
        //rcpdist.x = _mm256_mul_pd(_mm256_div_pd(k_1_0, k_view_distance), dist.x);
        //rcpdist.y = _mm256_mul_pd(_mm256_div_pd(k_1_0, k_view_distance), dist.y);

        v3__m256d cd[2];
        compute_color(me, pos0, pos1, qmask0, qmask1, &cd[0], &cd[1]);

        cd[0].x = _mm256_blendv_pd(k_0_0, cd[0].x, dist_hit_msk.x);
        cd[0].y = _mm256_blendv_pd(k_0_0, cd[0].y, dist_hit_msk.x);
        cd[0].z = _mm256_blendv_pd(k_0_0, cd[0].z, dist_hit_msk.x);
        cd[1].x = _mm256_blendv_pd(k_0_0, cd[1].x, dist_hit_msk.y);
        cd[1].y = _mm256_blendv_pd(k_0_0, cd[1].y, dist_hit_msk.y);
        cd[1].z = _mm256_blendv_pd(k_0_0, cd[1].z, dist_hit_msk.y);

        v3__m256 c;
        c.x = _mm256_castps128_ps256(_mm256_cvtpd_ps(cd[0].x));
        c.x = _mm256_insertf128_ps(c.x, _mm256_cvtpd_ps(cd[1].x), 1);
        c.y = _mm256_castps128_ps256(_mm256_cvtpd_ps(cd[0].y));
        c.y = _mm256_insertf128_ps(c.y, _mm256_cvtpd_ps(cd[1].y), 1);
        c.z = _mm256_castps128_ps256(_mm256_cvtpd_ps(cd[0].z));
        c.z = _mm256_insertf128_ps(c.z, _mm256_cvtpd_ps(cd[1].z), 1);

        c.x = _mm256_max_ps(k_0_0f, _mm256_min_ps(c.x, k_1_0f));
        c.y = _mm256_max_ps(k_0_0f, _mm256_min_ps(c.y, k_1_0f));
        c.z = _mm256_max_ps(k_0_0f, _mm256_min_ps(c.z, k_1_0f));

        dest_color.x = _mm256_add_ps(dest_color.x, c.x);
        dest_color.y = _mm256_add_ps(dest_color.y, c.y);
        dest_color.z = _mm256_add_ps(dest_color.z, c.z);

        _mm256_stream_ps((float *)(me->image_state + offset), dest_color.x);
        _mm256_stream_ps((float *)(me->image_state + offset + 32), dest_color.y);
        _mm256_stream_ps((float *)(me->image_state + offset + 64), dest_color.z);

        __m256 f = _mm256_set1_ps(255.0f / me->sample_count);

        v3__m256i ci;
        ci.x = _mm256_cvttps_epi32(_mm256_mul_ps(dest_color.x, f));
        ci.y = _mm256_cvttps_epi32(_mm256_mul_ps(dest_color.y, f));
        ci.z = _mm256_cvttps_epi32(_mm256_mul_ps(dest_color.z, f));

        __m256i cs = _mm256_or_si256(_mm256_or_si256(_mm256_slli_epi32(ci.x, 16),
                                                     _mm256_slli_epi32(ci.y, 8)), ci.z);

        _mm_stream_si128((__m128i *)&me->displayptr[(x + y * k_resolutionx) * 4],
                         _mm256_castsi256_si128(cs));
        _mm_stream_si128((__m128i *)&me->displayptr[(x + (y + 1) * k_resolutionx) * 4],
                         _mm256_extracti128_si256(cs, 1));

        offset += k_pixel_size_in_bytes * 8;
      }
    }
  }
}
//-----------------------------------------------------------------------------
static DWORD __stdcall
generate_fractal_thread(void *param)
{
  worker_thread_t *me = param;
  for (;;) {
    WaitForSingleObject(me->qj->main_thread_sem, INFINITE);
    generate_fractal(me->qj);
    ReleaseSemaphore(me->semaphore_handle, 1, NULL);
  }

  ExitThread(0);
  return 0;
}
//-----------------------------------------------------------------------------
static void
init_const(void)
{
  k_0_1 = _mm256_set1_pd(0.1);
  k_0_25 = _mm256_set1_pd(0.25);
  k_0_5 = _mm256_set1_pd(0.5);
  k_1_0 = _mm256_set1_pd(1.0);
  k_4_0 = _mm256_set1_pd(4.0);
  k_m1_0 = _mm256_set1_pd(-1.0);
  k_1023_0 = _mm256_set1_pd(1023.0);
  k_1_0f = _mm256_set1_ps(1.0f);
  k_half_sqrt2 = _mm256_set1_pd(0.5 * 1.4142135623730950488016887242097);
  k_000fffffffffffff = _mm256_set1_epi64x(0x000fffffffffffff);
  k_3fe0000000000000 = _mm256_set1_epi64x(0x3fe0000000000000);
  k_2pow52_0 = _mm256_set1_pd(4503599627370496.0);
  k_hit_distance = _mm256_set1_pd(2e-6);
  k_view_distance = _mm256_set1_pd(64.0);
  k_escape_threshold = _mm256_set1_pd(10.0);
  k_normal_epsilon = _mm256_set1_pd(1e-6);
  k_ln2_hi = _mm256_set1_pd(0.693359375);
  k_ln2_lo = _mm256_set1_pd(-2.121944400546905827679e-4);
  k_log_p0 = _mm256_set1_pd(7.70838733755885391666e0);
  k_log_p1 = _mm256_set1_pd(1.79368678507819816313e1);
  k_log_p2 = _mm256_set1_pd(1.44989225341610930846e1);
  k_log_p3 = _mm256_set1_pd(4.70579119878881725854e0);
  k_log_p4 = _mm256_set1_pd(4.97494994976747001425e-1);
  k_log_p5 = _mm256_set1_pd(1.01875663804580931796e-4);
  k_log_q0 = _mm256_set1_pd(2.31251620126765340583e1);
  k_log_q1 = _mm256_set1_pd(7.11544750618563894466e1);
  k_log_q2 = _mm256_set1_pd(8.29875266912776603211e1);
  k_log_q3 = _mm256_set1_pd(4.52279145837532221105e1);
  k_log_q4 = _mm256_set1_pd(1.12873587189167450590e1);
  k_quat = v4__m256d_set(_mm256_set1_pd(0.6), _mm256_set1_pd(0.2), _mm256_set1_pd(0.2), _mm256_set1_pd(-0.2));
}
//-----------------------------------------------------------------------------
static int
init(qjulia_t *me)
{
  WNDCLASS winclass = {
    .lpfnWndProc = winproc,
    .hInstance = GetModuleHandle(NULL),
    .hCursor = LoadCursor(NULL, IDC_ARROW),
    .lpszClassName = me->name
  };
  if (!RegisterClass(&winclass)) return 0;

  RECT rect = { 0, 0, k_resolutionx, k_resolutiony };
  if (!AdjustWindowRect(&rect, WS_OVERLAPPED | WS_SYSMENU | WS_CAPTION | WS_MINIMIZEBOX, FALSE))
    return 0;

  me->hwnd = CreateWindow(
    me->name, me->name,
    WS_OVERLAPPED | WS_SYSMENU | WS_CAPTION | WS_MINIMIZEBOX | WS_VISIBLE,
    CW_USEDEFAULT, CW_USEDEFAULT,
    rect.right - rect.left, rect.bottom - rect.top,
    NULL, NULL, NULL, 0);
  if (!me->hwnd) return 0;

  if (!(me->hdc = GetDC(me->hwnd))) return 0;

  BITMAPINFO bi = {
    .bmiHeader.biSize = sizeof(BITMAPINFOHEADER),
    .bmiHeader.biPlanes = 1,
    .bmiHeader.biBitCount = 32,
    .bmiHeader.biCompression = BI_RGB,
    .bmiHeader.biWidth = k_resolutionx,
    .bmiHeader.biHeight = k_resolutiony,
    .bmiHeader.biSizeImage = k_resolutionx * k_resolutiony
  };
  if (!(me->hbm = CreateDIBSection(me->hdc, &bi, DIB_RGB_COLORS, (void **)&me->displayptr,
                                   NULL, 0))) return 0;

  if (!(me->mdc = CreateCompatibleDC(me->hdc))) return 0;
  if (!SelectObject(me->mdc, me->hbm)) return 0;

  SYSTEM_INFO sysinfo;
  GetSystemInfo(&sysinfo);
  me->worker_thread_count = sysinfo.dwNumberOfProcessors;
  if (me->worker_thread_count >= k_thread_max_count) return 0;

  me->main_thread_sem = CreateSemaphore(NULL, 0, me->worker_thread_count, NULL);
  if (me->main_thread_sem == NULL) return 0;

  for (int i = 0; i < me->worker_thread_count; ++i) {
    me->thread[i].semaphore_handle = CreateSemaphore(NULL, 0, 1, NULL);
    if (me->thread[i].semaphore_handle == NULL) return 0;
  }

  for (int i = 0; i < me->worker_thread_count; ++i) {
    me->thread[i].qj = me;
    me->thread[i].tid = i;
    me->thread[i].thread_handle = CreateThread(NULL, 0, generate_fractal_thread,
                                               &me->thread[i], 0, NULL);
    if (me->thread[i].thread_handle == NULL) return 0;
  }

  me->eye_position[0] = 1.7;
  me->eye_position[1] = 0.2;
  me->eye_position[2] = 1.8;
  me->eye_focus[0] = 0.0;
  me->eye_focus[1] = 0.0;
  me->eye_focus[2] = 0.0;
  me->light_position[0][0] = 10.0;
  me->light_position[0][1] = 10.0;
  me->light_position[0][2] = -10.0;
  me->light_position[1][0] = 2.0;
  me->light_position[1][1] = 8.0;
  me->light_position[1][2] = 6.0;

  me->image_state = VirtualAlloc(NULL, k_resolutionx * k_resolutiony * k_pixel_size_in_bytes,
                                 MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
  if (me->image_state == NULL) return 0;
  memset(me->image_state, 0, k_resolutionx * k_resolutiony * k_pixel_size_in_bytes);

  me->prev_time = me->prev_fps_time = get_time(me);
  return 1;
}
//-----------------------------------------------------------------------------
static void
deinit(qjulia_t *me)
{
  if (me->image_state) VirtualFree(me->image_state, 0, MEM_RELEASE);
  if (me->mdc) DeleteDC(me->mdc);
  if (me->hbm) DeleteObject(me->hbm);
  if (me->hdc) ReleaseDC(me->hwnd, me->hdc);
}
//-----------------------------------------------------------------------------
static void
update(qjulia_t *me)
{
  v3__m256d eyep;
  eyep = v3__m256d_broadcast(&me->eye_position[0], &me->eye_position[1], &me->eye_position[2]);

  v3__m256d eyef;
  eyef = v3__m256d_broadcast(&me->eye_focus[0], &me->eye_focus[1], &me->eye_focus[2]);

  v3__m256d iz = v3__m256d_normalize(v3__m256d_sub(eyep, eyef));
  v3__m256d ix = v3__m256d_normalize(v3__m256d_cross(v3__m256d_set(k_0_0, k_1_0, k_0_0), iz));
  v3__m256d iy = v3__m256d_normalize(v3__m256d_cross(iz, ix));

  _mm_store_sd(&me->xaxis[0], _mm256_castpd256_pd128(ix.x));
  _mm_store_sd(&me->xaxis[1], _mm256_castpd256_pd128(ix.y));
  _mm_store_sd(&me->xaxis[2], _mm256_castpd256_pd128(ix.z));
  _mm_store_sd(&me->yaxis[0], _mm256_castpd256_pd128(iy.x));
  _mm_store_sd(&me->yaxis[1], _mm256_castpd256_pd128(iy.y));
  _mm_store_sd(&me->yaxis[2], _mm256_castpd256_pd128(iy.z));
  _mm_store_sd(&me->zaxis[0], _mm256_castpd256_pd128(iz.x));
  _mm_store_sd(&me->zaxis[1], _mm256_castpd256_pd128(iz.y));
  _mm_store_sd(&me->zaxis[2], _mm256_castpd256_pd128(iz.z));

  if (me->sample_count++ < k_sample_count) {
    InterlockedExchange((LONG *)&me->tileidx, 0);
    ReleaseSemaphore(me->main_thread_sem, me->worker_thread_count, NULL);

    HANDLE hsem[k_thread_max_count];
    for (int i = 0; i < me->worker_thread_count; ++i) {
      hsem[i] = me->thread[i].semaphore_handle;
    }
    WaitForMultipleObjects(me->worker_thread_count, hsem, TRUE, INFINITE);
  }

  BitBlt(me->hdc, 0, 0, k_resolutionx, k_resolutiony, me->mdc, 0, 0, SRCCOPY);
}
//-----------------------------------------------------------------------------
void
start(void)
{
  _MM_SET_DENORMALS_ZERO_MODE(_MM_DENORMALS_ZERO_ON);
  _MM_SET_FLUSH_ZERO_MODE(_MM_FLUSH_ZERO_ON);

  init_const();

  qjulia_t qj = {
    .heap = GetProcessHeap(),
    .name = "Quaternion Julia Sets"
  };
  QueryPerformanceFrequency(&qj.frequency);
  QueryPerformanceCounter(&qj.start_counter);

  if (!init(&qj)) {
    deinit(&qj);
    ExitProcess(1);
  }

  MSG msg = { 0 };
  for (;;) {
    if (PeekMessage(&msg, 0, 0, 0, PM_REMOVE)) {
      DispatchMessage(&msg);
      if (msg.message == WM_QUIT) break;
    } else {
      update_time_stats(&qj);
      update(&qj);
    }
  }

  deinit(&qj);
  ExitProcess(0);
}
//-----------------------------------------------------------------------------
