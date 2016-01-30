/* Include files */

#include "blascompat32.h"
#include "WorkstationModel_sfun.h"
#include "c9_WorkstationModel.h"
#include "mwmathutil.h"
#define CHARTINSTANCE_CHARTNUMBER      (chartInstance->chartNumber)
#define CHARTINSTANCE_INSTANCENUMBER   (chartInstance->instanceNumber)
#include "WorkstationModel_sfun_debug_macros.h"

/* Type Definitions */

/* Named Constants */
#define c9_event_ServerAvailable       (0)
#define CALL_EVENT                     (-1)

/* Variable Declarations */

/* Variable Definitions */
static const char * c9_debug_family_names[17] = { "NZ", "ResourceAssignment",
  "NextTask", "quotedleadtime", "TotalDelay", "CostFactor", "TotalPenalty",
  "TotalPenalty_delay", "Y", "I", "nargin", "nargout", "LongestWaitTime",
  "ProcessTime", "ResourceAvailability", "ResourceProductionState", "Resource" };

/* Function Declarations */
static void initialize_c9_WorkstationModel(SFc9_WorkstationModelInstanceStruct
  *chartInstance);
static void initialize_params_c9_WorkstationModel
  (SFc9_WorkstationModelInstanceStruct *chartInstance);
static void enable_c9_WorkstationModel(SFc9_WorkstationModelInstanceStruct
  *chartInstance);
static void disable_c9_WorkstationModel(SFc9_WorkstationModelInstanceStruct
  *chartInstance);
static void c9_update_debugger_state_c9_WorkstationModel
  (SFc9_WorkstationModelInstanceStruct *chartInstance);
static const mxArray *get_sim_state_c9_WorkstationModel
  (SFc9_WorkstationModelInstanceStruct *chartInstance);
static void set_sim_state_c9_WorkstationModel
  (SFc9_WorkstationModelInstanceStruct *chartInstance, const mxArray *c9_st);
static void finalize_c9_WorkstationModel(SFc9_WorkstationModelInstanceStruct
  *chartInstance);
static void sf_c9_WorkstationModel(SFc9_WorkstationModelInstanceStruct
  *chartInstance);
static void c9_chartstep_c9_WorkstationModel(SFc9_WorkstationModelInstanceStruct
  *chartInstance);
static void initSimStructsc9_WorkstationModel
  (SFc9_WorkstationModelInstanceStruct *chartInstance);
static void init_script_number_translation(uint32_T c9_machineNumber, uint32_T
  c9_chartNumber);
static const mxArray *c9_sf_marshallOut(void *chartInstanceVoid, void *c9_inData);
static real_T c9_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_Resource, const char_T *c9_identifier);
static real_T c9_b_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId);
static void c9_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c9_mxArrayInData, const char_T *c9_varName, void *c9_outData);
static const mxArray *c9_b_sf_marshallOut(void *chartInstanceVoid, void
  *c9_inData);
static const mxArray *c9_c_sf_marshallOut(void *chartInstanceVoid, void
  *c9_inData);
static const mxArray *c9_d_sf_marshallOut(void *chartInstanceVoid, real_T
  c9_inData_data[2], int32_T c9_inData_sizes[1]);
static void c9_c_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId,
  real_T c9_y_data[2], int32_T c9_y_sizes[1]);
static void c9_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c9_mxArrayInData, const char_T *c9_varName, real_T c9_outData_data[2],
  int32_T c9_outData_sizes[1]);
static const mxArray *c9_e_sf_marshallOut(void *chartInstanceVoid, real_T
  c9_inData_data[4], int32_T c9_inData_sizes[1]);
static void c9_d_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId,
  real_T c9_y_data[4], int32_T c9_y_sizes[1]);
static void c9_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c9_mxArrayInData, const char_T *c9_varName, real_T c9_outData_data[4],
  int32_T c9_outData_sizes[1]);
static void c9_e_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId,
  real_T c9_y[4]);
static void c9_d_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c9_mxArrayInData, const char_T *c9_varName, void *c9_outData);
static void c9_info_helper(c9_ResolvedFunctionInfo c9_info[56]);
static void c9_eml_int_forloop_overflow_check
  (SFc9_WorkstationModelInstanceStruct *chartInstance);
static void c9_power(SFc9_WorkstationModelInstanceStruct *chartInstance, real_T
                     c9_a[4], real_T c9_y[4]);
static void c9_eml_sort(SFc9_WorkstationModelInstanceStruct *chartInstance,
  real_T c9_x_data[4], int32_T c9_x_sizes[1], real_T c9_y_data[4], int32_T
  c9_y_sizes[1], int32_T c9_idx_data[4], int32_T c9_idx_sizes[1]);
static void c9_b_eml_int_forloop_overflow_check
  (SFc9_WorkstationModelInstanceStruct *chartInstance, int32_T c9_b);
static void c9_c_eml_int_forloop_overflow_check
  (SFc9_WorkstationModelInstanceStruct *chartInstance, int32_T c9_a);
static void c9_eml_sort_idx(SFc9_WorkstationModelInstanceStruct *chartInstance,
  real_T c9_x_data[4], int32_T c9_x_sizes[1], int32_T c9_idx_data[4], int32_T
  c9_idx_sizes[1]);
static void c9_d_eml_int_forloop_overflow_check
  (SFc9_WorkstationModelInstanceStruct *chartInstance, int32_T c9_b);
static const mxArray *c9_f_sf_marshallOut(void *chartInstanceVoid, void
  *c9_inData);
static int8_T c9_f_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId);
static void c9_e_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c9_mxArrayInData, const char_T *c9_varName, void *c9_outData);
static const mxArray *c9_g_sf_marshallOut(void *chartInstanceVoid, void
  *c9_inData);
static int32_T c9_g_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId);
static void c9_f_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c9_mxArrayInData, const char_T *c9_varName, void *c9_outData);
static uint8_T c9_h_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_b_is_active_c9_WorkstationModel, const
  char_T *c9_identifier);
static uint8_T c9_i_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId);
static void init_dsm_address_info(SFc9_WorkstationModelInstanceStruct
  *chartInstance);

/* Function Definitions */
static void initialize_c9_WorkstationModel(SFc9_WorkstationModelInstanceStruct
  *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  chartInstance->c9_is_active_c9_WorkstationModel = 0U;
}

static void initialize_params_c9_WorkstationModel
  (SFc9_WorkstationModelInstanceStruct *chartInstance)
{
}

static void enable_c9_WorkstationModel(SFc9_WorkstationModelInstanceStruct
  *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  sf_call_output_fcn_enable(chartInstance->S, 0, "ReleaseC1T1", 0);
  sf_call_output_fcn_enable(chartInstance->S, 1, "ReleaseC1T2", 0);
  sf_call_output_fcn_enable(chartInstance->S, 2, "ReleaseC2T1", 0);
  sf_call_output_fcn_enable(chartInstance->S, 3, "ReleaseC2T2", 0);
}

static void disable_c9_WorkstationModel(SFc9_WorkstationModelInstanceStruct
  *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  sf_call_output_fcn_disable(chartInstance->S, 0, "ReleaseC1T1", 0);
  sf_call_output_fcn_disable(chartInstance->S, 1, "ReleaseC1T2", 0);
  sf_call_output_fcn_disable(chartInstance->S, 2, "ReleaseC2T1", 0);
  sf_call_output_fcn_disable(chartInstance->S, 3, "ReleaseC2T2", 0);
}

static void c9_update_debugger_state_c9_WorkstationModel
  (SFc9_WorkstationModelInstanceStruct *chartInstance)
{
}

static const mxArray *get_sim_state_c9_WorkstationModel
  (SFc9_WorkstationModelInstanceStruct *chartInstance)
{
  const mxArray *c9_st;
  const mxArray *c9_y = NULL;
  real_T c9_hoistedGlobal;
  real_T c9_u;
  const mxArray *c9_b_y = NULL;
  uint8_T c9_b_hoistedGlobal;
  uint8_T c9_b_u;
  const mxArray *c9_c_y = NULL;
  real_T *c9_Resource;
  c9_Resource = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  c9_st = NULL;
  c9_st = NULL;
  c9_y = NULL;
  sf_mex_assign(&c9_y, sf_mex_createcellarray(2), FALSE);
  c9_hoistedGlobal = *c9_Resource;
  c9_u = c9_hoistedGlobal;
  c9_b_y = NULL;
  sf_mex_assign(&c9_b_y, sf_mex_create("y", &c9_u, 0, 0U, 0U, 0U, 0), FALSE);
  sf_mex_setcell(c9_y, 0, c9_b_y);
  c9_b_hoistedGlobal = chartInstance->c9_is_active_c9_WorkstationModel;
  c9_b_u = c9_b_hoistedGlobal;
  c9_c_y = NULL;
  sf_mex_assign(&c9_c_y, sf_mex_create("y", &c9_b_u, 3, 0U, 0U, 0U, 0), FALSE);
  sf_mex_setcell(c9_y, 1, c9_c_y);
  sf_mex_assign(&c9_st, c9_y, FALSE);
  return c9_st;
}

static void set_sim_state_c9_WorkstationModel
  (SFc9_WorkstationModelInstanceStruct *chartInstance, const mxArray *c9_st)
{
  const mxArray *c9_u;
  real_T *c9_Resource;
  c9_Resource = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  chartInstance->c9_doneDoubleBufferReInit = TRUE;
  c9_u = sf_mex_dup(c9_st);
  *c9_Resource = c9_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell
    (c9_u, 0)), "Resource");
  chartInstance->c9_is_active_c9_WorkstationModel = c9_h_emlrt_marshallIn
    (chartInstance, sf_mex_dup(sf_mex_getcell(c9_u, 1)),
     "is_active_c9_WorkstationModel");
  sf_mex_destroy(&c9_u);
  c9_update_debugger_state_c9_WorkstationModel(chartInstance);
  sf_mex_destroy(&c9_st);
}

static void finalize_c9_WorkstationModel(SFc9_WorkstationModelInstanceStruct
  *chartInstance)
{
}

static void sf_c9_WorkstationModel(SFc9_WorkstationModelInstanceStruct
  *chartInstance)
{
  int32_T c9_i0;
  int32_T c9_i1;
  int32_T c9_i2;
  int32_T c9_i3;
  real_T *c9_Resource;
  real_T (*c9_ResourceProductionState)[2];
  real_T (*c9_ResourceAvailability)[2];
  real_T (*c9_ProcessTime)[4];
  real_T (*c9_LongestWaitTime)[4];
  c9_Resource = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  c9_ResourceProductionState = (real_T (*)[2])ssGetInputPortSignal
    (chartInstance->S, 3);
  c9_ResourceAvailability = (real_T (*)[2])ssGetInputPortSignal(chartInstance->S,
    2);
  c9_ProcessTime = (real_T (*)[4])ssGetInputPortSignal(chartInstance->S, 1);
  c9_LongestWaitTime = (real_T (*)[4])ssGetInputPortSignal(chartInstance->S, 0);
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 6U, chartInstance->c9_sfEvent);
  for (c9_i0 = 0; c9_i0 < 4; c9_i0++) {
    _SFD_DATA_RANGE_CHECK((*c9_LongestWaitTime)[c9_i0], 0U);
  }

  for (c9_i1 = 0; c9_i1 < 4; c9_i1++) {
    _SFD_DATA_RANGE_CHECK((*c9_ProcessTime)[c9_i1], 1U);
  }

  for (c9_i2 = 0; c9_i2 < 2; c9_i2++) {
    _SFD_DATA_RANGE_CHECK((*c9_ResourceAvailability)[c9_i2], 2U);
  }

  for (c9_i3 = 0; c9_i3 < 2; c9_i3++) {
    _SFD_DATA_RANGE_CHECK((*c9_ResourceProductionState)[c9_i3], 3U);
  }

  _SFD_DATA_RANGE_CHECK(*c9_Resource, 4U);
  chartInstance->c9_sfEvent = c9_event_ServerAvailable;
  _SFD_CE_CALL(EVENT_BEFORE_BROADCAST_TAG, c9_event_ServerAvailable,
               chartInstance->c9_sfEvent);
  c9_chartstep_c9_WorkstationModel(chartInstance);
  _SFD_CE_CALL(EVENT_AFTER_BROADCAST_TAG, c9_event_ServerAvailable,
               chartInstance->c9_sfEvent);
  sf_debug_check_for_state_inconsistency(_WorkstationModelMachineNumber_,
    chartInstance->chartNumber, chartInstance->instanceNumber);
}

static void c9_chartstep_c9_WorkstationModel(SFc9_WorkstationModelInstanceStruct
  *chartInstance)
{
  int32_T c9_i4;
  real_T c9_LongestWaitTime[4];
  int32_T c9_i5;
  real_T c9_ProcessTime[4];
  int32_T c9_i6;
  real_T c9_ResourceAvailability[2];
  int32_T c9_i7;
  real_T c9_ResourceProductionState[2];
  uint32_T c9_debug_family_var_map[17];
  int32_T c9_NZ_sizes;
  real_T c9_NZ_data[4];
  real_T c9_ResourceAssignment;
  real_T c9_NextTask;
  real_T c9_quotedleadtime[4];
  real_T c9_TotalDelay[4];
  real_T c9_CostFactor[4];
  real_T c9_TotalPenalty[4];
  real_T c9_TotalPenalty_delay[4];
  int32_T c9_Y_sizes;
  real_T c9_Y_data[4];
  int32_T c9_I_sizes;
  real_T c9_I_data[4];
  int32_T c9_ResourceAssignment_sizes;
  real_T c9_ResourceAssignment_data[2];
  real_T c9_nargin = 4.0;
  real_T c9_nargout = 1.0;
  real_T c9_Resource;
  int32_T c9_i8;
  real_T c9_x[4];
  int32_T c9_idx;
  static int32_T c9_iv0[1] = { 4 };

  int32_T c9_ii_sizes;
  int32_T c9_ii;
  int32_T c9_b_ii;
  int32_T c9_a;
  int32_T c9_ii_data[4];
  boolean_T c9_b0;
  boolean_T c9_b1;
  boolean_T c9_b2;
  int32_T c9_i9;
  int32_T c9_tmp_sizes;
  int32_T c9_loop_ub;
  int32_T c9_i10;
  int32_T c9_tmp_data[4];
  int32_T c9_b_tmp_sizes[2];
  int32_T c9_iv1[2];
  int32_T c9_i11;
  int32_T c9_i12;
  int32_T c9_b_loop_ub;
  int32_T c9_i13;
  int32_T c9_b_tmp_data[4];
  int32_T c9_b_ii_sizes;
  int32_T c9_c_loop_ub;
  int32_T c9_i14;
  int32_T c9_b_ii_data[4];
  int32_T c9_d_loop_ub;
  int32_T c9_i15;
  int32_T c9_e_loop_ub;
  int32_T c9_i16;
  int32_T c9_i17;
  static real_T c9_dv0[4] = { 14.0, 21.0, 21.0, 28.0 };

  int32_T c9_i18;
  int32_T c9_i19;
  static real_T c9_b_x[4] = { 3.0, 3.0, 6.0, 6.0 };

  int32_T c9_i20;
  int32_T c9_k;
  int32_T c9_b_k;
  real_T c9_xk;
  real_T c9_c_x;
  real_T c9_extremum;
  real_T c9_maxval[4];
  int32_T c9_i21;
  real_T c9_b_maxval[4];
  int32_T c9_i22;
  int32_T c9_i23;
  int32_T c9_c_k;
  int32_T c9_d_k;
  real_T c9_b_xk;
  real_T c9_d_x;
  real_T c9_b_extremum;
  int32_T c9_i24;
  real_T c9_c_maxval[4];
  int32_T c9_i25;
  int32_T c9_x_sizes;
  int32_T c9_f_loop_ub;
  int32_T c9_i26;
  real_T c9_x_data[4];
  int32_T c9_b_x_sizes;
  int32_T c9_g_loop_ub;
  int32_T c9_i27;
  real_T c9_b_x_data[4];
  int32_T c9_b_I_sizes;
  int32_T c9_h_loop_ub;
  int32_T c9_i28;
  real_T c9_b_I_data[4];
  int32_T c9_i_loop_ub;
  int32_T c9_i29;
  int32_T c9_j_loop_ub;
  int32_T c9_i30;
  int32_T c9_i31;
  real_T c9_e_x[2];
  int32_T c9_b_idx;
  static int32_T c9_iv2[1] = { 2 };

  int32_T c9_c_ii_sizes;
  int32_T c9_c_ii;
  int32_T c9_d_ii;
  int32_T c9_b_a;
  int32_T c9_c_ii_data[2];
  boolean_T c9_b3;
  boolean_T c9_b4;
  boolean_T c9_b5;
  int32_T c9_i32;
  int32_T c9_c_tmp_sizes;
  int32_T c9_k_loop_ub;
  int32_T c9_i33;
  int32_T c9_c_tmp_data[2];
  int32_T c9_d_tmp_sizes[2];
  int32_T c9_iv3[2];
  int32_T c9_i34;
  int32_T c9_i35;
  int32_T c9_l_loop_ub;
  int32_T c9_i36;
  int32_T c9_d_tmp_data[2];
  int32_T c9_d_ii_sizes;
  int32_T c9_m_loop_ub;
  int32_T c9_i37;
  int32_T c9_d_ii_data[2];
  int32_T c9_n_loop_ub;
  int32_T c9_i38;
  int32_T c9_o_loop_ub;
  int32_T c9_i39;
  real_T *c9_b_Resource;
  real_T (*c9_b_ResourceProductionState)[2];
  real_T (*c9_b_ResourceAvailability)[2];
  real_T (*c9_b_ProcessTime)[4];
  real_T (*c9_b_LongestWaitTime)[4];
  boolean_T exitg1;
  boolean_T exitg2;
  boolean_T guard1 = FALSE;
  boolean_T guard2 = FALSE;
  c9_b_Resource = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  c9_b_ResourceProductionState = (real_T (*)[2])ssGetInputPortSignal
    (chartInstance->S, 3);
  c9_b_ResourceAvailability = (real_T (*)[2])ssGetInputPortSignal
    (chartInstance->S, 2);
  c9_b_ProcessTime = (real_T (*)[4])ssGetInputPortSignal(chartInstance->S, 1);
  c9_b_LongestWaitTime = (real_T (*)[4])ssGetInputPortSignal(chartInstance->S, 0);
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 6U, chartInstance->c9_sfEvent);
  for (c9_i4 = 0; c9_i4 < 4; c9_i4++) {
    c9_LongestWaitTime[c9_i4] = (*c9_b_LongestWaitTime)[c9_i4];
  }

  for (c9_i5 = 0; c9_i5 < 4; c9_i5++) {
    c9_ProcessTime[c9_i5] = (*c9_b_ProcessTime)[c9_i5];
  }

  for (c9_i6 = 0; c9_i6 < 2; c9_i6++) {
    c9_ResourceAvailability[c9_i6] = (*c9_b_ResourceAvailability)[c9_i6];
  }

  for (c9_i7 = 0; c9_i7 < 2; c9_i7++) {
    c9_ResourceProductionState[c9_i7] = (*c9_b_ResourceProductionState)[c9_i7];
  }

  sf_debug_symbol_scope_push_eml(0U, 17U, 18U, c9_debug_family_names,
    c9_debug_family_var_map);
  sf_debug_symbol_scope_add_eml_dyn_importable(c9_NZ_data, (const int32_T *)
    &c9_NZ_sizes, NULL, 0, 0, (void *)c9_e_sf_marshallOut, (void *)
    c9_c_sf_marshallIn);
  sf_debug_symbol_scope_add_eml_importable(&c9_ResourceAssignment, MAX_uint32_T,
    c9_sf_marshallOut, c9_sf_marshallIn);
  sf_debug_symbol_scope_add_eml_importable(&c9_NextTask, 2U, c9_sf_marshallOut,
    c9_sf_marshallIn);
  sf_debug_symbol_scope_add_eml_importable(c9_quotedleadtime, 3U,
    c9_c_sf_marshallOut, c9_d_sf_marshallIn);
  sf_debug_symbol_scope_add_eml_importable(c9_TotalDelay, 4U,
    c9_c_sf_marshallOut, c9_d_sf_marshallIn);
  sf_debug_symbol_scope_add_eml(c9_CostFactor, 5U, c9_c_sf_marshallOut);
  sf_debug_symbol_scope_add_eml_importable(c9_TotalPenalty, 6U,
    c9_c_sf_marshallOut, c9_d_sf_marshallIn);
  sf_debug_symbol_scope_add_eml_importable(c9_TotalPenalty_delay, 7U,
    c9_c_sf_marshallOut, c9_d_sf_marshallIn);
  sf_debug_symbol_scope_add_eml_dyn_importable(c9_Y_data, (const int32_T *)
    &c9_Y_sizes, NULL, 0, 8, (void *)c9_e_sf_marshallOut, (void *)
    c9_c_sf_marshallIn);
  sf_debug_symbol_scope_add_eml_dyn_importable(c9_I_data, (const int32_T *)
    &c9_I_sizes, NULL, 0, 9, (void *)c9_e_sf_marshallOut, (void *)
    c9_c_sf_marshallIn);
  sf_debug_symbol_scope_add_eml_dyn_importable(c9_ResourceAssignment_data, (
    const int32_T *)&c9_ResourceAssignment_sizes, NULL, 0, -1, (void *)
    c9_d_sf_marshallOut, (void *)c9_b_sf_marshallIn);
  sf_debug_symbol_scope_add_eml_importable(&c9_nargin, 10U, c9_sf_marshallOut,
    c9_sf_marshallIn);
  sf_debug_symbol_scope_add_eml_importable(&c9_nargout, 11U, c9_sf_marshallOut,
    c9_sf_marshallIn);
  sf_debug_symbol_scope_add_eml(c9_LongestWaitTime, 12U, c9_c_sf_marshallOut);
  sf_debug_symbol_scope_add_eml(c9_ProcessTime, 13U, c9_c_sf_marshallOut);
  sf_debug_symbol_scope_add_eml(c9_ResourceAvailability, 14U,
    c9_b_sf_marshallOut);
  sf_debug_symbol_scope_add_eml(c9_ResourceProductionState, 15U,
    c9_b_sf_marshallOut);
  sf_debug_symbol_scope_add_eml_importable(&c9_Resource, 16U, c9_sf_marshallOut,
    c9_sf_marshallIn);
  CV_EML_FCN(0, 0);
  _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 4);
  for (c9_i8 = 0; c9_i8 < 4; c9_i8++) {
    c9_x[c9_i8] = c9_ProcessTime[c9_i8];
  }

  c9_idx = 0;
  c9_ii_sizes = c9_iv0[0];
  c9_eml_int_forloop_overflow_check(chartInstance);
  c9_ii = 1;
  exitg2 = FALSE;
  while ((exitg2 == 0U) && (c9_ii < 5)) {
    c9_b_ii = c9_ii;
    guard2 = FALSE;
    if (c9_x[c9_b_ii - 1] != 0.0) {
      c9_a = c9_idx + 1;
      c9_idx = c9_a;
      c9_ii_data[c9_idx - 1] = c9_b_ii;
      if (c9_idx >= 4) {
        exitg2 = TRUE;
      } else {
        guard2 = TRUE;
      }
    } else {
      guard2 = TRUE;
    }

    if (guard2 == TRUE) {
      c9_ii++;
    }
  }

  c9_b0 = (1 > c9_idx);
  c9_b1 = c9_b0;
  c9_b2 = c9_b1;
  if (c9_b2) {
    c9_i9 = 0;
  } else {
    c9_i9 = _SFD_EML_ARRAY_BOUNDS_CHECK("", c9_idx, 1, 4, 0, 0);
  }

  c9_tmp_sizes = c9_i9;
  c9_loop_ub = c9_i9 - 1;
  for (c9_i10 = 0; c9_i10 <= c9_loop_ub; c9_i10++) {
    c9_tmp_data[c9_i10] = 1 + c9_i10;
  }

  c9_b_tmp_sizes[0] = 1;
  c9_iv1[0] = 1;
  c9_iv1[1] = c9_tmp_sizes;
  c9_b_tmp_sizes[1] = c9_iv1[1];
  c9_i11 = c9_b_tmp_sizes[0];
  c9_i12 = c9_b_tmp_sizes[1];
  c9_b_loop_ub = c9_tmp_sizes - 1;
  for (c9_i13 = 0; c9_i13 <= c9_b_loop_ub; c9_i13++) {
    c9_b_tmp_data[c9_i13] = c9_tmp_data[c9_i13];
  }

  sf_debug_vector_vector_index_check(4, 1, 1, c9_b_tmp_sizes[1]);
  c9_b_ii_sizes = c9_b_tmp_sizes[1];
  c9_c_loop_ub = c9_b_tmp_sizes[1] - 1;
  for (c9_i14 = 0; c9_i14 <= c9_c_loop_ub; c9_i14++) {
    c9_b_ii_data[c9_i14] = c9_ii_data[c9_b_tmp_data[c9_i14] - 1];
  }

  c9_ii_sizes = c9_b_ii_sizes;
  c9_d_loop_ub = c9_b_ii_sizes - 1;
  for (c9_i15 = 0; c9_i15 <= c9_d_loop_ub; c9_i15++) {
    c9_ii_data[c9_i15] = c9_b_ii_data[c9_i15];
  }

  c9_NZ_sizes = c9_ii_sizes;
  c9_e_loop_ub = c9_ii_sizes - 1;
  for (c9_i16 = 0; c9_i16 <= c9_e_loop_ub; c9_i16++) {
    c9_NZ_data[c9_i16] = (real_T)c9_ii_data[c9_i16];
  }

  _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 6);
  c9_ResourceAssignment = 1.0;
  sf_debug_symbol_switch(1U, 1U);
  _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 7);
  c9_NextTask = 1.0;
  _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 8);
  c9_Resource = 1.0;
  _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 10);
  if (CV_EML_IF(0, 1, 0, (real_T)(c9_NZ_sizes == 0) == 0.0)) {
    _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 12);
    for (c9_i17 = 0; c9_i17 < 4; c9_i17++) {
      c9_quotedleadtime[c9_i17] = c9_dv0[c9_i17];
    }

    _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 14);
    for (c9_i18 = 0; c9_i18 < 4; c9_i18++) {
      c9_TotalDelay[c9_i18] = c9_LongestWaitTime[c9_i18] + c9_ProcessTime[c9_i18];
    }

    _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 16);
    for (c9_i19 = 0; c9_i19 < 4; c9_i19++) {
      c9_CostFactor[c9_i19] = c9_b_x[c9_i19];
    }

    _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 18);
    for (c9_i20 = 0; c9_i20 < 4; c9_i20++) {
      c9_x[c9_i20] = c9_quotedleadtime[c9_i20] - c9_TotalDelay[c9_i20];
    }

    c9_eml_int_forloop_overflow_check(chartInstance);
    for (c9_k = 1; c9_k < 5; c9_k++) {
      c9_b_k = c9_k - 1;
      c9_xk = c9_x[c9_b_k];
      c9_c_x = c9_xk;
      c9_extremum = muDoubleScalarMax(c9_c_x, 1.0);
      c9_maxval[c9_b_k] = c9_extremum;
    }

    for (c9_i21 = 0; c9_i21 < 4; c9_i21++) {
      c9_b_maxval[c9_i21] = c9_maxval[c9_i21];
    }

    c9_power(chartInstance, c9_b_maxval, c9_x);
    for (c9_i22 = 0; c9_i22 < 4; c9_i22++) {
      c9_TotalPenalty[c9_i22] = c9_b_x[c9_i22] / c9_x[c9_i22];
    }

    _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 20);
    for (c9_i23 = 0; c9_i23 < 4; c9_i23++) {
      c9_x[c9_i23] = (c9_quotedleadtime[c9_i23] - c9_TotalDelay[c9_i23]) - 5.0;
    }

    c9_eml_int_forloop_overflow_check(chartInstance);
    for (c9_c_k = 1; c9_c_k < 5; c9_c_k++) {
      c9_d_k = c9_c_k - 1;
      c9_b_xk = c9_x[c9_d_k];
      c9_d_x = c9_b_xk;
      c9_b_extremum = muDoubleScalarMax(c9_d_x, 1.0);
      c9_maxval[c9_d_k] = c9_b_extremum;
    }

    for (c9_i24 = 0; c9_i24 < 4; c9_i24++) {
      c9_c_maxval[c9_i24] = c9_maxval[c9_i24];
    }

    c9_power(chartInstance, c9_c_maxval, c9_x);
    for (c9_i25 = 0; c9_i25 < 4; c9_i25++) {
      c9_TotalPenalty_delay[c9_i25] = c9_b_x[c9_i25] / c9_x[c9_i25];
    }

    _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 25);
    c9_x_sizes = c9_NZ_sizes;
    c9_f_loop_ub = c9_NZ_sizes - 1;
    for (c9_i26 = 0; c9_i26 <= c9_f_loop_ub; c9_i26++) {
      c9_x_data[c9_i26] = c9_TotalPenalty[(int32_T)c9_NZ_data[c9_i26] - 1];
    }

    c9_b_x_sizes = c9_x_sizes;
    c9_g_loop_ub = c9_x_sizes - 1;
    for (c9_i27 = 0; c9_i27 <= c9_g_loop_ub; c9_i27++) {
      c9_b_x_data[c9_i27] = c9_x_data[c9_i27];
    }

    c9_eml_sort(chartInstance, c9_b_x_data, *(int32_T (*)[1])&c9_b_x_sizes,
                c9_x_data, *(int32_T (*)[1])&c9_x_sizes, c9_ii_data, *(int32_T (*)
      [1])&c9_ii_sizes);
    c9_b_I_sizes = c9_ii_sizes;
    c9_h_loop_ub = c9_ii_sizes - 1;
    for (c9_i28 = 0; c9_i28 <= c9_h_loop_ub; c9_i28++) {
      c9_b_I_data[c9_i28] = (real_T)c9_ii_data[c9_i28];
    }

    c9_Y_sizes = c9_x_sizes;
    c9_i_loop_ub = c9_x_sizes - 1;
    for (c9_i29 = 0; c9_i29 <= c9_i_loop_ub; c9_i29++) {
      c9_Y_data[c9_i29] = c9_x_data[c9_i29];
    }

    c9_I_sizes = c9_b_I_sizes;
    c9_j_loop_ub = c9_b_I_sizes - 1;
    for (c9_i30 = 0; c9_i30 <= c9_j_loop_ub; c9_i30++) {
      c9_I_data[c9_i30] = c9_b_I_data[c9_i30];
    }

    _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 26);
    (real_T)_SFD_EML_ARRAY_BOUNDS_CHECK("I", 1, 1, c9_I_sizes, 1, 0);
    c9_NextTask = c9_NZ_data[_SFD_EML_ARRAY_BOUNDS_CHECK("NZ", (int32_T)
      c9_I_data[0], 1, c9_NZ_sizes, 1, 0) - 1];
    _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 33);
    for (c9_i31 = 0; c9_i31 < 2; c9_i31++) {
      c9_e_x[c9_i31] = c9_ResourceAvailability[c9_i31];
    }

    c9_b_idx = 0;
    c9_c_ii_sizes = c9_iv2[0];
    c9_b_eml_int_forloop_overflow_check(chartInstance, 2);
    c9_c_ii = 1;
    exitg1 = FALSE;
    while ((exitg1 == 0U) && (c9_c_ii < 3)) {
      c9_d_ii = c9_c_ii;
      guard1 = FALSE;
      if (c9_e_x[c9_d_ii - 1] != 0.0) {
        c9_b_a = c9_b_idx + 1;
        c9_b_idx = c9_b_a;
        c9_c_ii_data[c9_b_idx - 1] = c9_d_ii;
        if (c9_b_idx >= 2) {
          exitg1 = TRUE;
        } else {
          guard1 = TRUE;
        }
      } else {
        guard1 = TRUE;
      }

      if (guard1 == TRUE) {
        c9_c_ii++;
      }
    }

    c9_b3 = (1 > c9_b_idx);
    c9_b4 = c9_b3;
    c9_b5 = c9_b4;
    if (c9_b5) {
      c9_i32 = 0;
    } else {
      c9_i32 = _SFD_EML_ARRAY_BOUNDS_CHECK("", c9_b_idx, 1, 2, 0, 0);
    }

    c9_c_tmp_sizes = c9_i32;
    c9_k_loop_ub = c9_i32 - 1;
    for (c9_i33 = 0; c9_i33 <= c9_k_loop_ub; c9_i33++) {
      c9_c_tmp_data[c9_i33] = 1 + c9_i33;
    }

    c9_d_tmp_sizes[0] = 1;
    c9_iv3[0] = 1;
    c9_iv3[1] = c9_c_tmp_sizes;
    c9_d_tmp_sizes[1] = c9_iv3[1];
    c9_i34 = c9_d_tmp_sizes[0];
    c9_i35 = c9_d_tmp_sizes[1];
    c9_l_loop_ub = c9_c_tmp_sizes - 1;
    for (c9_i36 = 0; c9_i36 <= c9_l_loop_ub; c9_i36++) {
      c9_d_tmp_data[c9_i36] = c9_c_tmp_data[c9_i36];
    }

    sf_debug_vector_vector_index_check(2, 1, 1, c9_d_tmp_sizes[1]);
    c9_d_ii_sizes = c9_d_tmp_sizes[1];
    c9_m_loop_ub = c9_d_tmp_sizes[1] - 1;
    for (c9_i37 = 0; c9_i37 <= c9_m_loop_ub; c9_i37++) {
      c9_d_ii_data[c9_i37] = c9_c_ii_data[c9_d_tmp_data[c9_i37] - 1];
    }

    c9_c_ii_sizes = c9_d_ii_sizes;
    c9_n_loop_ub = c9_d_ii_sizes - 1;
    for (c9_i38 = 0; c9_i38 <= c9_n_loop_ub; c9_i38++) {
      c9_c_ii_data[c9_i38] = c9_d_ii_data[c9_i38];
    }

    c9_ResourceAssignment_sizes = c9_c_ii_sizes;
    c9_o_loop_ub = c9_c_ii_sizes - 1;
    for (c9_i39 = 0; c9_i39 <= c9_o_loop_ub; c9_i39++) {
      c9_ResourceAssignment_data[c9_i39] = (real_T)c9_c_ii_data[c9_i39];
    }

    sf_debug_symbol_switch(1U, 10U);
    _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 40);
    (real_T)_SFD_EML_ARRAY_BOUNDS_CHECK("ResourceAssignment", 1, 1,
      c9_ResourceAssignment_sizes, 1, 0);
    switch ((int32_T)c9_ResourceAssignment_data[0]) {
     case 1:
      CV_EML_SWITCH(0, 1, 0, 1);
      _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 42);
      break;

     case 2:
      CV_EML_SWITCH(0, 1, 0, 2);
      _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 44);
      c9_Resource = 2.0;
      break;

     default:
      CV_EML_SWITCH(0, 1, 0, 0);
      _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 46);
      break;
    }

    _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 51);
    switch ((int32_T)c9_NextTask) {
     case 1:
      CV_EML_SWITCH(0, 1, 1, 1);
      _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 53);
      sf_call_output_fcn_call(chartInstance->S, 0, "ReleaseC1T1", 0);
      break;

     case 2:
      CV_EML_SWITCH(0, 1, 1, 2);
      _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 55);
      sf_call_output_fcn_call(chartInstance->S, 1, "ReleaseC1T2", 0);
      break;

     case 3:
      CV_EML_SWITCH(0, 1, 1, 3);
      _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 57);
      sf_call_output_fcn_call(chartInstance->S, 2, "ReleaseC2T1", 0);
      break;

     case 4:
      CV_EML_SWITCH(0, 1, 1, 4);
      _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, 59);
      sf_call_output_fcn_call(chartInstance->S, 3, "ReleaseC2T2", 0);
      break;

     default:
      CV_EML_SWITCH(0, 1, 1, 0);
      break;
    }
  }

  _SFD_EML_CALL(0U, chartInstance->c9_sfEvent, -59);
  sf_debug_symbol_scope_pop();
  *c9_b_Resource = c9_Resource;
  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 6U, chartInstance->c9_sfEvent);
}

static void initSimStructsc9_WorkstationModel
  (SFc9_WorkstationModelInstanceStruct *chartInstance)
{
}

static void init_script_number_translation(uint32_T c9_machineNumber, uint32_T
  c9_chartNumber)
{
}

static const mxArray *c9_sf_marshallOut(void *chartInstanceVoid, void *c9_inData)
{
  const mxArray *c9_mxArrayOutData = NULL;
  real_T c9_u;
  const mxArray *c9_y = NULL;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_mxArrayOutData = NULL;
  c9_u = *(real_T *)c9_inData;
  c9_y = NULL;
  sf_mex_assign(&c9_y, sf_mex_create("y", &c9_u, 0, 0U, 0U, 0U, 0), FALSE);
  sf_mex_assign(&c9_mxArrayOutData, c9_y, FALSE);
  return c9_mxArrayOutData;
}

static real_T c9_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_Resource, const char_T *c9_identifier)
{
  real_T c9_y;
  emlrtMsgIdentifier c9_thisId;
  c9_thisId.fIdentifier = c9_identifier;
  c9_thisId.fParent = NULL;
  c9_y = c9_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c9_Resource),
    &c9_thisId);
  sf_mex_destroy(&c9_Resource);
  return c9_y;
}

static real_T c9_b_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId)
{
  real_T c9_y;
  real_T c9_d0;
  sf_mex_import(c9_parentId, sf_mex_dup(c9_u), &c9_d0, 1, 0, 0U, 0, 0U, 0);
  c9_y = c9_d0;
  sf_mex_destroy(&c9_u);
  return c9_y;
}

static void c9_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c9_mxArrayInData, const char_T *c9_varName, void *c9_outData)
{
  const mxArray *c9_Resource;
  const char_T *c9_identifier;
  emlrtMsgIdentifier c9_thisId;
  real_T c9_y;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_Resource = sf_mex_dup(c9_mxArrayInData);
  c9_identifier = c9_varName;
  c9_thisId.fIdentifier = c9_identifier;
  c9_thisId.fParent = NULL;
  c9_y = c9_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c9_Resource),
    &c9_thisId);
  sf_mex_destroy(&c9_Resource);
  *(real_T *)c9_outData = c9_y;
  sf_mex_destroy(&c9_mxArrayInData);
}

static const mxArray *c9_b_sf_marshallOut(void *chartInstanceVoid, void
  *c9_inData)
{
  const mxArray *c9_mxArrayOutData = NULL;
  int32_T c9_i40;
  real_T c9_b_inData[2];
  int32_T c9_i41;
  real_T c9_u[2];
  const mxArray *c9_y = NULL;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_mxArrayOutData = NULL;
  for (c9_i40 = 0; c9_i40 < 2; c9_i40++) {
    c9_b_inData[c9_i40] = (*(real_T (*)[2])c9_inData)[c9_i40];
  }

  for (c9_i41 = 0; c9_i41 < 2; c9_i41++) {
    c9_u[c9_i41] = c9_b_inData[c9_i41];
  }

  c9_y = NULL;
  sf_mex_assign(&c9_y, sf_mex_create("y", c9_u, 0, 0U, 1U, 0U, 1, 2), FALSE);
  sf_mex_assign(&c9_mxArrayOutData, c9_y, FALSE);
  return c9_mxArrayOutData;
}

static const mxArray *c9_c_sf_marshallOut(void *chartInstanceVoid, void
  *c9_inData)
{
  const mxArray *c9_mxArrayOutData = NULL;
  int32_T c9_i42;
  real_T c9_b_inData[4];
  int32_T c9_i43;
  real_T c9_u[4];
  const mxArray *c9_y = NULL;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_mxArrayOutData = NULL;
  for (c9_i42 = 0; c9_i42 < 4; c9_i42++) {
    c9_b_inData[c9_i42] = (*(real_T (*)[4])c9_inData)[c9_i42];
  }

  for (c9_i43 = 0; c9_i43 < 4; c9_i43++) {
    c9_u[c9_i43] = c9_b_inData[c9_i43];
  }

  c9_y = NULL;
  sf_mex_assign(&c9_y, sf_mex_create("y", c9_u, 0, 0U, 1U, 0U, 1, 4), FALSE);
  sf_mex_assign(&c9_mxArrayOutData, c9_y, FALSE);
  return c9_mxArrayOutData;
}

static const mxArray *c9_d_sf_marshallOut(void *chartInstanceVoid, real_T
  c9_inData_data[2], int32_T c9_inData_sizes[1])
{
  const mxArray *c9_mxArrayOutData = NULL;
  int32_T c9_b_inData_sizes;
  int32_T c9_loop_ub;
  int32_T c9_i44;
  real_T c9_b_inData_data[2];
  int32_T c9_u_sizes;
  int32_T c9_b_loop_ub;
  int32_T c9_i45;
  real_T c9_u_data[2];
  const mxArray *c9_y = NULL;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_mxArrayOutData = NULL;
  c9_b_inData_sizes = c9_inData_sizes[0];
  c9_loop_ub = c9_inData_sizes[0] - 1;
  for (c9_i44 = 0; c9_i44 <= c9_loop_ub; c9_i44++) {
    c9_b_inData_data[c9_i44] = c9_inData_data[c9_i44];
  }

  c9_u_sizes = c9_b_inData_sizes;
  c9_b_loop_ub = c9_b_inData_sizes - 1;
  for (c9_i45 = 0; c9_i45 <= c9_b_loop_ub; c9_i45++) {
    c9_u_data[c9_i45] = c9_b_inData_data[c9_i45];
  }

  c9_y = NULL;
  sf_mex_assign(&c9_y, sf_mex_create("y", c9_u_data, 0, 0U, 1U, 0U, 1,
    c9_u_sizes), FALSE);
  sf_mex_assign(&c9_mxArrayOutData, c9_y, FALSE);
  return c9_mxArrayOutData;
}

static void c9_c_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId,
  real_T c9_y_data[2], int32_T c9_y_sizes[1])
{
  static uint32_T c9_uv0[1] = { 2U };

  uint32_T c9_uv1[1];
  static boolean_T c9_bv0[1] = { TRUE };

  boolean_T c9_bv1[1];
  int32_T c9_tmp_sizes;
  real_T c9_tmp_data[2];
  int32_T c9_loop_ub;
  int32_T c9_i46;
  c9_uv1[0] = c9_uv0[0];
  c9_bv1[0] = c9_bv0[0];
  sf_mex_import_vs(c9_parentId, sf_mex_dup(c9_u), c9_tmp_data, 1, 0, 0U, 1, 0U,
                   1, c9_bv1, c9_uv1, &c9_tmp_sizes);
  c9_y_sizes[0] = c9_tmp_sizes;
  c9_loop_ub = c9_tmp_sizes - 1;
  for (c9_i46 = 0; c9_i46 <= c9_loop_ub; c9_i46++) {
    c9_y_data[c9_i46] = c9_tmp_data[c9_i46];
  }

  sf_mex_destroy(&c9_u);
}

static void c9_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c9_mxArrayInData, const char_T *c9_varName, real_T c9_outData_data[2],
  int32_T c9_outData_sizes[1])
{
  const mxArray *c9_ResourceAssignment;
  const char_T *c9_identifier;
  emlrtMsgIdentifier c9_thisId;
  int32_T c9_y_sizes;
  real_T c9_y_data[2];
  int32_T c9_loop_ub;
  int32_T c9_i47;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_ResourceAssignment = sf_mex_dup(c9_mxArrayInData);
  c9_identifier = c9_varName;
  c9_thisId.fIdentifier = c9_identifier;
  c9_thisId.fParent = NULL;
  c9_c_emlrt_marshallIn(chartInstance, sf_mex_dup(c9_ResourceAssignment),
                        &c9_thisId, c9_y_data, *(int32_T (*)[1])&c9_y_sizes);
  sf_mex_destroy(&c9_ResourceAssignment);
  c9_outData_sizes[0] = c9_y_sizes;
  c9_loop_ub = c9_y_sizes - 1;
  for (c9_i47 = 0; c9_i47 <= c9_loop_ub; c9_i47++) {
    c9_outData_data[c9_i47] = c9_y_data[c9_i47];
  }

  sf_mex_destroy(&c9_mxArrayInData);
}

static const mxArray *c9_e_sf_marshallOut(void *chartInstanceVoid, real_T
  c9_inData_data[4], int32_T c9_inData_sizes[1])
{
  const mxArray *c9_mxArrayOutData = NULL;
  int32_T c9_b_inData_sizes;
  int32_T c9_loop_ub;
  int32_T c9_i48;
  real_T c9_b_inData_data[4];
  int32_T c9_u_sizes;
  int32_T c9_b_loop_ub;
  int32_T c9_i49;
  real_T c9_u_data[4];
  const mxArray *c9_y = NULL;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_mxArrayOutData = NULL;
  c9_b_inData_sizes = c9_inData_sizes[0];
  c9_loop_ub = c9_inData_sizes[0] - 1;
  for (c9_i48 = 0; c9_i48 <= c9_loop_ub; c9_i48++) {
    c9_b_inData_data[c9_i48] = c9_inData_data[c9_i48];
  }

  c9_u_sizes = c9_b_inData_sizes;
  c9_b_loop_ub = c9_b_inData_sizes - 1;
  for (c9_i49 = 0; c9_i49 <= c9_b_loop_ub; c9_i49++) {
    c9_u_data[c9_i49] = c9_b_inData_data[c9_i49];
  }

  c9_y = NULL;
  sf_mex_assign(&c9_y, sf_mex_create("y", c9_u_data, 0, 0U, 1U, 0U, 1,
    c9_u_sizes), FALSE);
  sf_mex_assign(&c9_mxArrayOutData, c9_y, FALSE);
  return c9_mxArrayOutData;
}

static void c9_d_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId,
  real_T c9_y_data[4], int32_T c9_y_sizes[1])
{
  static uint32_T c9_uv2[1] = { 4U };

  uint32_T c9_uv3[1];
  static boolean_T c9_bv2[1] = { TRUE };

  boolean_T c9_bv3[1];
  int32_T c9_tmp_sizes;
  real_T c9_tmp_data[4];
  int32_T c9_loop_ub;
  int32_T c9_i50;
  c9_uv3[0] = c9_uv2[0];
  c9_bv3[0] = c9_bv2[0];
  sf_mex_import_vs(c9_parentId, sf_mex_dup(c9_u), c9_tmp_data, 1, 0, 0U, 1, 0U,
                   1, c9_bv3, c9_uv3, &c9_tmp_sizes);
  c9_y_sizes[0] = c9_tmp_sizes;
  c9_loop_ub = c9_tmp_sizes - 1;
  for (c9_i50 = 0; c9_i50 <= c9_loop_ub; c9_i50++) {
    c9_y_data[c9_i50] = c9_tmp_data[c9_i50];
  }

  sf_mex_destroy(&c9_u);
}

static void c9_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c9_mxArrayInData, const char_T *c9_varName, real_T c9_outData_data[4],
  int32_T c9_outData_sizes[1])
{
  const mxArray *c9_I;
  const char_T *c9_identifier;
  emlrtMsgIdentifier c9_thisId;
  int32_T c9_y_sizes;
  real_T c9_y_data[4];
  int32_T c9_loop_ub;
  int32_T c9_i51;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_I = sf_mex_dup(c9_mxArrayInData);
  c9_identifier = c9_varName;
  c9_thisId.fIdentifier = c9_identifier;
  c9_thisId.fParent = NULL;
  c9_d_emlrt_marshallIn(chartInstance, sf_mex_dup(c9_I), &c9_thisId, c9_y_data, *
                        (int32_T (*)[1])&c9_y_sizes);
  sf_mex_destroy(&c9_I);
  c9_outData_sizes[0] = c9_y_sizes;
  c9_loop_ub = c9_y_sizes - 1;
  for (c9_i51 = 0; c9_i51 <= c9_loop_ub; c9_i51++) {
    c9_outData_data[c9_i51] = c9_y_data[c9_i51];
  }

  sf_mex_destroy(&c9_mxArrayInData);
}

static void c9_e_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId,
  real_T c9_y[4])
{
  real_T c9_dv1[4];
  int32_T c9_i52;
  sf_mex_import(c9_parentId, sf_mex_dup(c9_u), c9_dv1, 1, 0, 0U, 1, 0U, 1, 4);
  for (c9_i52 = 0; c9_i52 < 4; c9_i52++) {
    c9_y[c9_i52] = c9_dv1[c9_i52];
  }

  sf_mex_destroy(&c9_u);
}

static void c9_d_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c9_mxArrayInData, const char_T *c9_varName, void *c9_outData)
{
  const mxArray *c9_TotalPenalty_delay;
  const char_T *c9_identifier;
  emlrtMsgIdentifier c9_thisId;
  real_T c9_y[4];
  int32_T c9_i53;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_TotalPenalty_delay = sf_mex_dup(c9_mxArrayInData);
  c9_identifier = c9_varName;
  c9_thisId.fIdentifier = c9_identifier;
  c9_thisId.fParent = NULL;
  c9_e_emlrt_marshallIn(chartInstance, sf_mex_dup(c9_TotalPenalty_delay),
                        &c9_thisId, c9_y);
  sf_mex_destroy(&c9_TotalPenalty_delay);
  for (c9_i53 = 0; c9_i53 < 4; c9_i53++) {
    (*(real_T (*)[4])c9_outData)[c9_i53] = c9_y[c9_i53];
  }

  sf_mex_destroy(&c9_mxArrayInData);
}

const mxArray *sf_c9_WorkstationModel_get_eml_resolved_functions_info(void)
{
  const mxArray *c9_nameCaptureInfo;
  c9_ResolvedFunctionInfo c9_info[56];
  const mxArray *c9_m0 = NULL;
  int32_T c9_i54;
  c9_ResolvedFunctionInfo *c9_r0;
  c9_nameCaptureInfo = NULL;
  c9_nameCaptureInfo = NULL;
  c9_info_helper(c9_info);
  sf_mex_assign(&c9_m0, sf_mex_createstruct("nameCaptureInfo", 1, 56), FALSE);
  for (c9_i54 = 0; c9_i54 < 56; c9_i54++) {
    c9_r0 = &c9_info[c9_i54];
    sf_mex_addfield(c9_m0, sf_mex_create("nameCaptureInfo", c9_r0->context, 15,
      0U, 0U, 0U, 2, 1, strlen(c9_r0->context)), "context", "nameCaptureInfo",
                    c9_i54);
    sf_mex_addfield(c9_m0, sf_mex_create("nameCaptureInfo", c9_r0->name, 15, 0U,
      0U, 0U, 2, 1, strlen(c9_r0->name)), "name", "nameCaptureInfo", c9_i54);
    sf_mex_addfield(c9_m0, sf_mex_create("nameCaptureInfo", c9_r0->dominantType,
      15, 0U, 0U, 0U, 2, 1, strlen(c9_r0->dominantType)), "dominantType",
                    "nameCaptureInfo", c9_i54);
    sf_mex_addfield(c9_m0, sf_mex_create("nameCaptureInfo", c9_r0->resolved, 15,
      0U, 0U, 0U, 2, 1, strlen(c9_r0->resolved)), "resolved", "nameCaptureInfo",
                    c9_i54);
    sf_mex_addfield(c9_m0, sf_mex_create("nameCaptureInfo", &c9_r0->fileTimeLo,
      7, 0U, 0U, 0U, 0), "fileTimeLo", "nameCaptureInfo", c9_i54);
    sf_mex_addfield(c9_m0, sf_mex_create("nameCaptureInfo", &c9_r0->fileTimeHi,
      7, 0U, 0U, 0U, 0), "fileTimeHi", "nameCaptureInfo", c9_i54);
    sf_mex_addfield(c9_m0, sf_mex_create("nameCaptureInfo", &c9_r0->mFileTimeLo,
      7, 0U, 0U, 0U, 0), "mFileTimeLo", "nameCaptureInfo", c9_i54);
    sf_mex_addfield(c9_m0, sf_mex_create("nameCaptureInfo", &c9_r0->mFileTimeHi,
      7, 0U, 0U, 0U, 0), "mFileTimeHi", "nameCaptureInfo", c9_i54);
  }

  sf_mex_assign(&c9_nameCaptureInfo, c9_m0, FALSE);
  sf_mex_emlrtNameCapturePostProcessR2012a(&c9_nameCaptureInfo);
  return c9_nameCaptureInfo;
}

static void c9_info_helper(c9_ResolvedFunctionInfo c9_info[56])
{
  c9_info[0].context = "";
  c9_info[0].name = "find";
  c9_info[0].dominantType = "double";
  c9_info[0].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/elmat/find.m";
  c9_info[0].fileTimeLo = 1303167806U;
  c9_info[0].fileTimeHi = 0U;
  c9_info[0].mFileTimeLo = 0U;
  c9_info[0].mFileTimeHi = 0U;
  c9_info[1].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/elmat/find.m!eml_find";
  c9_info[1].name = "eml_index_class";
  c9_info[1].dominantType = "";
  c9_info[1].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  c9_info[1].fileTimeLo = 1286840378U;
  c9_info[1].fileTimeHi = 0U;
  c9_info[1].mFileTimeLo = 0U;
  c9_info[1].mFileTimeHi = 0U;
  c9_info[2].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/elmat/find.m!eml_find";
  c9_info[2].name = "eml_scalar_eg";
  c9_info[2].dominantType = "double";
  c9_info[2].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_scalar_eg.m";
  c9_info[2].fileTimeLo = 1286840396U;
  c9_info[2].fileTimeHi = 0U;
  c9_info[2].mFileTimeLo = 0U;
  c9_info[2].mFileTimeHi = 0U;
  c9_info[3].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/elmat/find.m!eml_find";
  c9_info[3].name = "eml_int_forloop_overflow_check";
  c9_info[3].dominantType = "";
  c9_info[3].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_int_forloop_overflow_check.m";
  c9_info[3].fileTimeLo = 1311276916U;
  c9_info[3].fileTimeHi = 0U;
  c9_info[3].mFileTimeLo = 0U;
  c9_info[3].mFileTimeHi = 0U;
  c9_info[4].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_int_forloop_overflow_check.m!eml_int_forloop_overflow_check_helper";
  c9_info[4].name = "intmax";
  c9_info[4].dominantType = "char";
  c9_info[4].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/elmat/intmax.m";
  c9_info[4].fileTimeLo = 1311276916U;
  c9_info[4].fileTimeHi = 0U;
  c9_info[4].mFileTimeLo = 0U;
  c9_info[4].mFileTimeHi = 0U;
  c9_info[5].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/elmat/find.m!eml_find";
  c9_info[5].name = "eml_index_plus";
  c9_info[5].dominantType = "int32";
  c9_info[5].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_plus.m";
  c9_info[5].fileTimeLo = 1286840378U;
  c9_info[5].fileTimeHi = 0U;
  c9_info[5].mFileTimeLo = 0U;
  c9_info[5].mFileTimeHi = 0U;
  c9_info[6].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_plus.m";
  c9_info[6].name = "eml_index_class";
  c9_info[6].dominantType = "";
  c9_info[6].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  c9_info[6].fileTimeLo = 1286840378U;
  c9_info[6].fileTimeHi = 0U;
  c9_info[6].mFileTimeLo = 0U;
  c9_info[6].mFileTimeHi = 0U;
  c9_info[7].context = "";
  c9_info[7].name = "max";
  c9_info[7].dominantType = "double";
  c9_info[7].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/datafun/max.m";
  c9_info[7].fileTimeLo = 1311276916U;
  c9_info[7].fileTimeHi = 0U;
  c9_info[7].mFileTimeLo = 0U;
  c9_info[7].mFileTimeHi = 0U;
  c9_info[8].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/datafun/max.m";
  c9_info[8].name = "eml_min_or_max";
  c9_info[8].dominantType = "char";
  c9_info[8].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_min_or_max.m";
  c9_info[8].fileTimeLo = 1303167812U;
  c9_info[8].fileTimeHi = 0U;
  c9_info[8].mFileTimeLo = 0U;
  c9_info[8].mFileTimeHi = 0U;
  c9_info[9].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_min_or_max.m!eml_bin_extremum";
  c9_info[9].name = "eml_scalar_eg";
  c9_info[9].dominantType = "double";
  c9_info[9].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_scalar_eg.m";
  c9_info[9].fileTimeLo = 1286840396U;
  c9_info[9].fileTimeHi = 0U;
  c9_info[9].mFileTimeLo = 0U;
  c9_info[9].mFileTimeHi = 0U;
  c9_info[10].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_min_or_max.m!eml_bin_extremum";
  c9_info[10].name = "eml_scalexp_alloc";
  c9_info[10].dominantType = "double";
  c9_info[10].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_scalexp_alloc.m";
  c9_info[10].fileTimeLo = 1286840396U;
  c9_info[10].fileTimeHi = 0U;
  c9_info[10].mFileTimeLo = 0U;
  c9_info[10].mFileTimeHi = 0U;
  c9_info[11].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_min_or_max.m!eml_bin_extremum";
  c9_info[11].name = "eml_index_class";
  c9_info[11].dominantType = "";
  c9_info[11].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  c9_info[11].fileTimeLo = 1286840378U;
  c9_info[11].fileTimeHi = 0U;
  c9_info[11].mFileTimeLo = 0U;
  c9_info[11].mFileTimeHi = 0U;
  c9_info[12].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_min_or_max.m!eml_bin_extremum";
  c9_info[12].name = "eml_int_forloop_overflow_check";
  c9_info[12].dominantType = "";
  c9_info[12].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_int_forloop_overflow_check.m";
  c9_info[12].fileTimeLo = 1311276916U;
  c9_info[12].fileTimeHi = 0U;
  c9_info[12].mFileTimeLo = 0U;
  c9_info[12].mFileTimeHi = 0U;
  c9_info[13].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_min_or_max.m!eml_scalar_bin_extremum";
  c9_info[13].name = "eml_scalar_eg";
  c9_info[13].dominantType = "double";
  c9_info[13].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_scalar_eg.m";
  c9_info[13].fileTimeLo = 1286840396U;
  c9_info[13].fileTimeHi = 0U;
  c9_info[13].mFileTimeLo = 0U;
  c9_info[13].mFileTimeHi = 0U;
  c9_info[14].context = "";
  c9_info[14].name = "power";
  c9_info[14].dominantType = "double";
  c9_info[14].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/power.m";
  c9_info[14].fileTimeLo = 1307672840U;
  c9_info[14].fileTimeHi = 0U;
  c9_info[14].mFileTimeLo = 0U;
  c9_info[14].mFileTimeHi = 0U;
  c9_info[15].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/power.m";
  c9_info[15].name = "eml_scalar_eg";
  c9_info[15].dominantType = "double";
  c9_info[15].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_scalar_eg.m";
  c9_info[15].fileTimeLo = 1286840396U;
  c9_info[15].fileTimeHi = 0U;
  c9_info[15].mFileTimeLo = 0U;
  c9_info[15].mFileTimeHi = 0U;
  c9_info[16].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/power.m";
  c9_info[16].name = "eml_scalexp_alloc";
  c9_info[16].dominantType = "double";
  c9_info[16].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_scalexp_alloc.m";
  c9_info[16].fileTimeLo = 1286840396U;
  c9_info[16].fileTimeHi = 0U;
  c9_info[16].mFileTimeLo = 0U;
  c9_info[16].mFileTimeHi = 0U;
  c9_info[17].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/power.m";
  c9_info[17].name = "eml_scalar_floor";
  c9_info[17].dominantType = "double";
  c9_info[17].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/elfun/eml_scalar_floor.m";
  c9_info[17].fileTimeLo = 1286840326U;
  c9_info[17].fileTimeHi = 0U;
  c9_info[17].mFileTimeLo = 0U;
  c9_info[17].mFileTimeHi = 0U;
  c9_info[18].context = "";
  c9_info[18].name = "rdivide";
  c9_info[18].dominantType = "double";
  c9_info[18].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/rdivide.m";
  c9_info[18].fileTimeLo = 1286840444U;
  c9_info[18].fileTimeHi = 0U;
  c9_info[18].mFileTimeLo = 0U;
  c9_info[18].mFileTimeHi = 0U;
  c9_info[19].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/ops/rdivide.m";
  c9_info[19].name = "eml_div";
  c9_info[19].dominantType = "double";
  c9_info[19].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_div.m";
  c9_info[19].fileTimeLo = 1313369410U;
  c9_info[19].fileTimeHi = 0U;
  c9_info[19].mFileTimeLo = 0U;
  c9_info[19].mFileTimeHi = 0U;
  c9_info[20].context = "";
  c9_info[20].name = "sort";
  c9_info[20].dominantType = "double";
  c9_info[20].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/datafun/sort.m";
  c9_info[20].fileTimeLo = 1303167808U;
  c9_info[20].fileTimeHi = 0U;
  c9_info[20].mFileTimeLo = 0U;
  c9_info[20].mFileTimeHi = 0U;
  c9_info[21].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/datafun/sort.m";
  c9_info[21].name = "eml_sort";
  c9_info[21].dominantType = "double";
  c9_info[21].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort.m";
  c9_info[21].fileTimeLo = 1314758212U;
  c9_info[21].fileTimeHi = 0U;
  c9_info[21].mFileTimeLo = 0U;
  c9_info[21].mFileTimeHi = 0U;
  c9_info[22].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort.m";
  c9_info[22].name = "eml_nonsingleton_dim";
  c9_info[22].dominantType = "double";
  c9_info[22].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_nonsingleton_dim.m";
  c9_info[22].fileTimeLo = 1307672842U;
  c9_info[22].fileTimeHi = 0U;
  c9_info[22].mFileTimeLo = 0U;
  c9_info[22].mFileTimeHi = 0U;
  c9_info[23].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_nonsingleton_dim.m";
  c9_info[23].name = "eml_index_class";
  c9_info[23].dominantType = "";
  c9_info[23].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  c9_info[23].fileTimeLo = 1286840378U;
  c9_info[23].fileTimeHi = 0U;
  c9_info[23].mFileTimeLo = 0U;
  c9_info[23].mFileTimeHi = 0U;
  c9_info[24].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort.m";
  c9_info[24].name = "eml_assert_valid_dim";
  c9_info[24].dominantType = "int32";
  c9_info[24].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_assert_valid_dim.m";
  c9_info[24].fileTimeLo = 1286840294U;
  c9_info[24].fileTimeHi = 0U;
  c9_info[24].mFileTimeLo = 0U;
  c9_info[24].mFileTimeHi = 0U;
  c9_info[25].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_assert_valid_dim.m";
  c9_info[25].name = "eml_scalar_floor";
  c9_info[25].dominantType = "int32";
  c9_info[25].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/elfun/eml_scalar_floor.m";
  c9_info[25].fileTimeLo = 1286840326U;
  c9_info[25].fileTimeHi = 0U;
  c9_info[25].mFileTimeLo = 0U;
  c9_info[25].mFileTimeHi = 0U;
  c9_info[26].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_assert_valid_dim.m";
  c9_info[26].name = "eml_index_class";
  c9_info[26].dominantType = "";
  c9_info[26].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  c9_info[26].fileTimeLo = 1286840378U;
  c9_info[26].fileTimeHi = 0U;
  c9_info[26].mFileTimeLo = 0U;
  c9_info[26].mFileTimeHi = 0U;
  c9_info[27].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_assert_valid_dim.m";
  c9_info[27].name = "intmax";
  c9_info[27].dominantType = "char";
  c9_info[27].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/elmat/intmax.m";
  c9_info[27].fileTimeLo = 1311276916U;
  c9_info[27].fileTimeHi = 0U;
  c9_info[27].mFileTimeLo = 0U;
  c9_info[27].mFileTimeHi = 0U;
  c9_info[28].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort.m";
  c9_info[28].name = "eml_scalar_eg";
  c9_info[28].dominantType = "double";
  c9_info[28].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_scalar_eg.m";
  c9_info[28].fileTimeLo = 1286840396U;
  c9_info[28].fileTimeHi = 0U;
  c9_info[28].mFileTimeLo = 0U;
  c9_info[28].mFileTimeHi = 0U;
  c9_info[29].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort.m";
  c9_info[29].name = "eml_index_class";
  c9_info[29].dominantType = "";
  c9_info[29].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  c9_info[29].fileTimeLo = 1286840378U;
  c9_info[29].fileTimeHi = 0U;
  c9_info[29].mFileTimeLo = 0U;
  c9_info[29].mFileTimeHi = 0U;
  c9_info[30].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort.m";
  c9_info[30].name = "eml_matrix_vstride";
  c9_info[30].dominantType = "int32";
  c9_info[30].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_matrix_vstride.m";
  c9_info[30].fileTimeLo = 1286840388U;
  c9_info[30].fileTimeHi = 0U;
  c9_info[30].mFileTimeLo = 0U;
  c9_info[30].mFileTimeHi = 0U;
  c9_info[31].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_matrix_vstride.m";
  c9_info[31].name = "eml_index_minus";
  c9_info[31].dominantType = "int32";
  c9_info[31].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_minus.m";
  c9_info[31].fileTimeLo = 1286840378U;
  c9_info[31].fileTimeHi = 0U;
  c9_info[31].mFileTimeLo = 0U;
  c9_info[31].mFileTimeHi = 0U;
  c9_info[32].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_minus.m";
  c9_info[32].name = "eml_index_class";
  c9_info[32].dominantType = "";
  c9_info[32].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  c9_info[32].fileTimeLo = 1286840378U;
  c9_info[32].fileTimeHi = 0U;
  c9_info[32].mFileTimeLo = 0U;
  c9_info[32].mFileTimeHi = 0U;
  c9_info[33].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_matrix_vstride.m";
  c9_info[33].name = "eml_index_class";
  c9_info[33].dominantType = "";
  c9_info[33].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  c9_info[33].fileTimeLo = 1286840378U;
  c9_info[33].fileTimeHi = 0U;
  c9_info[33].mFileTimeLo = 0U;
  c9_info[33].mFileTimeHi = 0U;
  c9_info[34].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_matrix_vstride.m";
  c9_info[34].name = "eml_size_prod";
  c9_info[34].dominantType = "int32";
  c9_info[34].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_size_prod.m";
  c9_info[34].fileTimeLo = 1286840398U;
  c9_info[34].fileTimeHi = 0U;
  c9_info[34].mFileTimeLo = 0U;
  c9_info[34].mFileTimeHi = 0U;
  c9_info[35].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_size_prod.m";
  c9_info[35].name = "eml_index_class";
  c9_info[35].dominantType = "";
  c9_info[35].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  c9_info[35].fileTimeLo = 1286840378U;
  c9_info[35].fileTimeHi = 0U;
  c9_info[35].mFileTimeLo = 0U;
  c9_info[35].mFileTimeHi = 0U;
  c9_info[36].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_size_prod.m";
  c9_info[36].name = "eml_int_forloop_overflow_check";
  c9_info[36].dominantType = "";
  c9_info[36].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_int_forloop_overflow_check.m";
  c9_info[36].fileTimeLo = 1311276916U;
  c9_info[36].fileTimeHi = 0U;
  c9_info[36].mFileTimeLo = 0U;
  c9_info[36].mFileTimeHi = 0U;
  c9_info[37].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_size_prod.m";
  c9_info[37].name = "eml_index_times";
  c9_info[37].dominantType = "int32";
  c9_info[37].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_times.m";
  c9_info[37].fileTimeLo = 1286840380U;
  c9_info[37].fileTimeHi = 0U;
  c9_info[37].mFileTimeLo = 0U;
  c9_info[37].mFileTimeHi = 0U;
  c9_info[38].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_times.m";
  c9_info[38].name = "eml_index_class";
  c9_info[38].dominantType = "";
  c9_info[38].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  c9_info[38].fileTimeLo = 1286840378U;
  c9_info[38].fileTimeHi = 0U;
  c9_info[38].mFileTimeLo = 0U;
  c9_info[38].mFileTimeHi = 0U;
  c9_info[39].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort.m";
  c9_info[39].name = "eml_index_minus";
  c9_info[39].dominantType = "double";
  c9_info[39].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_minus.m";
  c9_info[39].fileTimeLo = 1286840378U;
  c9_info[39].fileTimeHi = 0U;
  c9_info[39].mFileTimeLo = 0U;
  c9_info[39].mFileTimeHi = 0U;
  c9_info[40].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort.m";
  c9_info[40].name = "eml_index_times";
  c9_info[40].dominantType = "int32";
  c9_info[40].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_times.m";
  c9_info[40].fileTimeLo = 1286840380U;
  c9_info[40].fileTimeHi = 0U;
  c9_info[40].mFileTimeLo = 0U;
  c9_info[40].mFileTimeHi = 0U;
  c9_info[41].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort.m";
  c9_info[41].name = "eml_matrix_npages";
  c9_info[41].dominantType = "int32";
  c9_info[41].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_matrix_npages.m";
  c9_info[41].fileTimeLo = 1286840386U;
  c9_info[41].fileTimeHi = 0U;
  c9_info[41].mFileTimeLo = 0U;
  c9_info[41].mFileTimeHi = 0U;
  c9_info[42].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_matrix_npages.m";
  c9_info[42].name = "eml_index_plus";
  c9_info[42].dominantType = "int32";
  c9_info[42].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_plus.m";
  c9_info[42].fileTimeLo = 1286840378U;
  c9_info[42].fileTimeHi = 0U;
  c9_info[42].mFileTimeLo = 0U;
  c9_info[42].mFileTimeHi = 0U;
  c9_info[43].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_matrix_npages.m";
  c9_info[43].name = "eml_index_class";
  c9_info[43].dominantType = "";
  c9_info[43].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  c9_info[43].fileTimeLo = 1286840378U;
  c9_info[43].fileTimeHi = 0U;
  c9_info[43].mFileTimeLo = 0U;
  c9_info[43].mFileTimeHi = 0U;
  c9_info[44].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_matrix_npages.m";
  c9_info[44].name = "eml_size_prod";
  c9_info[44].dominantType = "int32";
  c9_info[44].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_size_prod.m";
  c9_info[44].fileTimeLo = 1286840398U;
  c9_info[44].fileTimeHi = 0U;
  c9_info[44].mFileTimeLo = 0U;
  c9_info[44].mFileTimeHi = 0U;
  c9_info[45].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort.m";
  c9_info[45].name = "eml_int_forloop_overflow_check";
  c9_info[45].dominantType = "";
  c9_info[45].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_int_forloop_overflow_check.m";
  c9_info[45].fileTimeLo = 1311276916U;
  c9_info[45].fileTimeHi = 0U;
  c9_info[45].mFileTimeLo = 0U;
  c9_info[45].mFileTimeHi = 0U;
  c9_info[46].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort.m";
  c9_info[46].name = "eml_index_plus";
  c9_info[46].dominantType = "int32";
  c9_info[46].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_plus.m";
  c9_info[46].fileTimeLo = 1286840378U;
  c9_info[46].fileTimeHi = 0U;
  c9_info[46].mFileTimeLo = 0U;
  c9_info[46].mFileTimeHi = 0U;
  c9_info[47].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort.m";
  c9_info[47].name = "eml_sort_idx";
  c9_info[47].dominantType = "double";
  c9_info[47].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort_idx.m";
  c9_info[47].fileTimeLo = 1305339604U;
  c9_info[47].fileTimeHi = 0U;
  c9_info[47].mFileTimeLo = 0U;
  c9_info[47].mFileTimeHi = 0U;
  c9_info[48].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort_idx.m";
  c9_info[48].name = "eml_index_class";
  c9_info[48].dominantType = "";
  c9_info[48].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  c9_info[48].fileTimeLo = 1286840378U;
  c9_info[48].fileTimeHi = 0U;
  c9_info[48].mFileTimeLo = 0U;
  c9_info[48].mFileTimeHi = 0U;
  c9_info[49].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort_idx.m";
  c9_info[49].name = "eml_index_plus";
  c9_info[49].dominantType = "int32";
  c9_info[49].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_plus.m";
  c9_info[49].fileTimeLo = 1286840378U;
  c9_info[49].fileTimeHi = 0U;
  c9_info[49].mFileTimeLo = 0U;
  c9_info[49].mFileTimeHi = 0U;
  c9_info[50].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort_idx.m";
  c9_info[50].name = "eml_int_forloop_overflow_check";
  c9_info[50].dominantType = "";
  c9_info[50].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_int_forloop_overflow_check.m";
  c9_info[50].fileTimeLo = 1311276916U;
  c9_info[50].fileTimeHi = 0U;
  c9_info[50].mFileTimeLo = 0U;
  c9_info[50].mFileTimeHi = 0U;
  c9_info[51].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort_idx.m";
  c9_info[51].name = "eml_index_minus";
  c9_info[51].dominantType = "int32";
  c9_info[51].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_minus.m";
  c9_info[51].fileTimeLo = 1286840378U;
  c9_info[51].fileTimeHi = 0U;
  c9_info[51].mFileTimeLo = 0U;
  c9_info[51].mFileTimeHi = 0U;
  c9_info[52].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort_idx.m";
  c9_info[52].name = "eml_sort_le";
  c9_info[52].dominantType = "int32";
  c9_info[52].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort_le.m";
  c9_info[52].fileTimeLo = 1292212110U;
  c9_info[52].fileTimeHi = 0U;
  c9_info[52].mFileTimeLo = 0U;
  c9_info[52].mFileTimeHi = 0U;
  c9_info[53].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort_le.m!eml_sort_ascending_le";
  c9_info[53].name = "eml_relop";
  c9_info[53].dominantType = "function_handle";
  c9_info[53].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_relop.m";
  c9_info[53].fileTimeLo = 1292212110U;
  c9_info[53].fileTimeHi = 0U;
  c9_info[53].mFileTimeLo = 0U;
  c9_info[53].mFileTimeHi = 0U;
  c9_info[54].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort_le.m!eml_sort_ascending_le";
  c9_info[54].name = "isnan";
  c9_info[54].dominantType = "double";
  c9_info[54].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/elmat/isnan.m";
  c9_info[54].fileTimeLo = 1286840360U;
  c9_info[54].fileTimeHi = 0U;
  c9_info[54].mFileTimeLo = 0U;
  c9_info[54].mFileTimeHi = 0U;
  c9_info[55].context =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_sort_idx.m";
  c9_info[55].name = "eml_index_times";
  c9_info[55].dominantType = "int32";
  c9_info[55].resolved =
    "[ILXE]C:/Program Files/MATLAB/R2012a/toolbox/eml/lib/matlab/eml/eml_index_times.m";
  c9_info[55].fileTimeLo = 1286840380U;
  c9_info[55].fileTimeHi = 0U;
  c9_info[55].mFileTimeLo = 0U;
  c9_info[55].mFileTimeHi = 0U;
}

static void c9_eml_int_forloop_overflow_check
  (SFc9_WorkstationModelInstanceStruct *chartInstance)
{
}

static void c9_power(SFc9_WorkstationModelInstanceStruct *chartInstance, real_T
                     c9_a[4], real_T c9_y[4])
{
  int32_T c9_k;
  real_T c9_b_k;
  real_T c9_ak;
  for (c9_k = 0; c9_k < 4; c9_k++) {
    c9_b_k = 1.0 + (real_T)c9_k;
    c9_ak = c9_a[(int32_T)c9_b_k - 1];
    c9_y[(int32_T)c9_b_k - 1] = muDoubleScalarPower(c9_ak, 2.0);
  }
}

static void c9_eml_sort(SFc9_WorkstationModelInstanceStruct *chartInstance,
  real_T c9_x_data[4], int32_T c9_x_sizes[1], real_T c9_y_data[4], int32_T
  c9_y_sizes[1], int32_T c9_idx_data[4], int32_T c9_idx_sizes[1])
{
  int32_T c9_dim;
  int32_T c9_b_dim;
  int32_T c9_x;
  int32_T c9_b_x;
  boolean_T c9_b6;
  int32_T c9_i55;
  static char_T c9_cv0[53] = { 'C', 'o', 'd', 'e', 'r', ':', 'M', 'A', 'T', 'L',
    'A', 'B', ':', 'g', 'e', 't', 'd', 'i', 'm', 'a', 'r', 'g', '_', 'd', 'i',
    'm', 'e', 'n', 's', 'i', 'o', 'n', 'M', 'u', 's', 't', 'B', 'e', 'P', 'o',
    's', 'i', 't', 'i', 'v', 'e', 'I', 'n', 't', 'e', 'g', 'e', 'r' };

  char_T c9_u[53];
  const mxArray *c9_y = NULL;
  int32_T c9_i56;
  real_T c9_d1;
  real_T c9_vlen;
  real_T c9_dv2[2];
  int32_T c9_tmp_sizes;
  int32_T c9_loop_ub;
  int32_T c9_i57;
  real_T c9_tmp_data[4];
  int32_T c9_vwork_sizes;
  int32_T c9_iidx_sizes;
  int32_T c9_b_loop_ub;
  int32_T c9_i58;
  int32_T c9_iidx_data[4];
  int32_T c9_c_dim;
  int32_T c9_a;
  int32_T c9_n;
  int32_T c9_j;
  int32_T c9_vstride;
  int32_T c9_c_loop_ub;
  int32_T c9_k;
  real_T c9_d2;
  int32_T c9_b_a;
  real_T c9_b;
  real_T c9_d3;
  int32_T c9_i59;
  real_T c9_c_a;
  real_T c9_d4;
  int32_T c9_i60;
  int32_T c9_c;
  int32_T c9_d_a;
  int32_T c9_b_b;
  int32_T c9_vspread;
  int32_T c9_d_dim;
  int32_T c9_e_a;
  int32_T c9_b_c;
  int32_T c9_i;
  int32_T c9_b_i;
  int32_T c9_i2;
  int32_T c9_c_i;
  int32_T c9_i1;
  int32_T c9_f_a;
  int32_T c9_c_b;
  int32_T c9_b_j;
  int32_T c9_g_a;
  int32_T c9_h_a;
  int32_T c9_ix;
  int32_T c9_i61;
  int32_T c9_d_loop_ub;
  int32_T c9_b_k;
  real_T c9_c_k;
  real_T c9_vwork_data[4];
  int32_T c9_i_a;
  int32_T c9_d_b;
  int32_T c9_b_vwork_sizes;
  int32_T c9_e_loop_ub;
  int32_T c9_i62;
  real_T c9_b_vwork_data[4];
  int32_T c9_i63;
  int32_T c9_f_loop_ub;
  int32_T c9_d_k;
  int32_T c9_j_a;
  int32_T c9_e_b;
  c9_dim = 2;
  if ((real_T)c9_x_sizes[0] != 1.0) {
    c9_dim = 1;
  }

  c9_b_dim = c9_dim;
  c9_x = c9_b_dim;
  c9_b_x = c9_x;
  if (c9_b_dim == c9_b_x) {
    c9_b6 = TRUE;
  } else {
    c9_b6 = FALSE;
  }

  if (c9_b6) {
  } else {
    for (c9_i55 = 0; c9_i55 < 53; c9_i55++) {
      c9_u[c9_i55] = c9_cv0[c9_i55];
    }

    c9_y = NULL;
    sf_mex_assign(&c9_y, sf_mex_create("y", c9_u, 10, 0U, 1U, 0U, 2, 1, 53),
                  FALSE);
    sf_mex_call_debug("error", 0U, 1U, 14, sf_mex_call_debug("message", 1U, 1U,
      14, c9_y));
  }

  c9_i56 = c9_dim;
  if (c9_i56 <= 1) {
    c9_d1 = (real_T)c9_x_sizes[0];
  } else {
    c9_d1 = 1.0;
  }

  c9_vlen = c9_d1;
  c9_dv2[0] = c9_vlen;
  c9_dv2[1] = 1.0;
  c9_tmp_sizes = (int32_T)c9_dv2[0];
  c9_loop_ub = (int32_T)c9_dv2[0] - 1;
  for (c9_i57 = 0; c9_i57 <= c9_loop_ub; c9_i57++) {
    c9_tmp_data[c9_i57] = 0.0;
  }

  c9_vwork_sizes = c9_tmp_sizes;
  c9_y_sizes[0] = c9_x_sizes[0];
  c9_dv2[0] = (real_T)c9_x_sizes[0];
  c9_dv2[1] = 1.0;
  c9_iidx_sizes = (int32_T)c9_dv2[0];
  c9_b_loop_ub = (int32_T)c9_dv2[0] - 1;
  for (c9_i58 = 0; c9_i58 <= c9_b_loop_ub; c9_i58++) {
    c9_iidx_data[c9_i58] = 0;
  }

  c9_idx_sizes[0] = c9_iidx_sizes;
  c9_c_dim = c9_dim;
  c9_a = c9_c_dim;
  c9_n = c9_a;
  c9_j = c9_n - 1;
  c9_vstride = 1;
  c9_b_eml_int_forloop_overflow_check(chartInstance, c9_j);
  c9_c_loop_ub = c9_j;
  c9_k = 1;
  while (c9_k <= c9_c_loop_ub) {
    c9_d2 = (real_T)c9_x_sizes[0];
    c9_b_a = c9_vstride;
    c9_b = c9_d2;
    c9_d3 = muDoubleScalarRound(c9_b);
    if (c9_d3 < 2.147483648E+9) {
      if (c9_d3 >= -2.147483648E+9) {
        c9_i59 = (int32_T)c9_d3;
      } else {
        c9_i59 = MIN_int32_T;
      }
    } else if (c9_d3 >= 2.147483648E+9) {
      c9_i59 = MAX_int32_T;
    } else {
      c9_i59 = 0;
    }

    c9_vstride = c9_b_a * c9_i59;
    c9_k = 2;
  }

  c9_c_a = c9_vlen;
  c9_d4 = muDoubleScalarRound(c9_c_a);
  if (c9_d4 < 2.147483648E+9) {
    if (c9_d4 >= -2.147483648E+9) {
      c9_i60 = (int32_T)c9_d4;
    } else {
      c9_i60 = MIN_int32_T;
    }
  } else if (c9_d4 >= 2.147483648E+9) {
    c9_i60 = MAX_int32_T;
  } else {
    c9_i60 = 0;
  }

  c9_c = c9_i60;
  c9_d_a = c9_c - 1;
  c9_b_b = c9_vstride;
  c9_vspread = c9_d_a * c9_b_b;
  c9_d_dim = c9_dim;
  c9_e_a = c9_d_dim;
  c9_b_c = c9_e_a;
  c9_i = c9_b_c + 1;
  c9_b_i = c9_i;
  c9_c_eml_int_forloop_overflow_check(chartInstance, c9_b_i);
  c9_i2 = 0;
  c9_b_eml_int_forloop_overflow_check(chartInstance, 1);
  c9_c_i = 1;
  while (c9_c_i <= 1) {
    c9_i1 = c9_i2;
    c9_f_a = c9_i2;
    c9_c_b = c9_vspread;
    c9_i2 = c9_f_a + c9_c_b;
    c9_b_eml_int_forloop_overflow_check(chartInstance, c9_vstride);
    for (c9_b_j = 1; c9_b_j <= c9_vstride; c9_b_j++) {
      c9_g_a = c9_i1 + 1;
      c9_i1 = c9_g_a;
      c9_h_a = c9_i2 + 1;
      c9_i2 = c9_h_a;
      c9_ix = c9_i1;
      c9_i61 = (int32_T)c9_vlen - 1;
      c9_d_loop_ub = c9_i61;
      for (c9_b_k = 0; c9_b_k <= c9_d_loop_ub; c9_b_k++) {
        c9_c_k = 1.0 + (real_T)c9_b_k;
        c9_vwork_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", (int32_T)c9_c_k, 1,
          c9_vwork_sizes, 1, 0) - 1] = c9_x_data[_SFD_EML_ARRAY_BOUNDS_CHECK("",
          c9_ix, 1, c9_x_sizes[0], 1, 0) - 1];
        c9_i_a = c9_ix;
        c9_d_b = c9_vstride;
        c9_ix = c9_i_a + c9_d_b;
      }

      c9_b_vwork_sizes = c9_vwork_sizes;
      c9_e_loop_ub = c9_vwork_sizes - 1;
      for (c9_i62 = 0; c9_i62 <= c9_e_loop_ub; c9_i62++) {
        c9_b_vwork_data[c9_i62] = c9_vwork_data[c9_i62];
      }

      c9_eml_sort_idx(chartInstance, c9_b_vwork_data, *(int32_T (*)[1])&
                      c9_b_vwork_sizes, c9_iidx_data, *(int32_T (*)[1])&
                      c9_iidx_sizes);
      c9_ix = c9_i1;
      c9_i63 = (int32_T)c9_vlen - 1;
      c9_f_loop_ub = c9_i63;
      for (c9_d_k = 0; c9_d_k <= c9_f_loop_ub; c9_d_k++) {
        c9_c_k = 1.0 + (real_T)c9_d_k;
        c9_y_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_ix, 1, c9_y_sizes[0], 1, 0)
          - 1] = c9_vwork_data[_SFD_EML_ARRAY_BOUNDS_CHECK("",
          c9_iidx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", (int32_T)c9_c_k, 1,
          c9_iidx_sizes, 1, 0) - 1], 1, c9_vwork_sizes, 1, 0) - 1];
        c9_idx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_ix, 1, c9_idx_sizes[0], 1,
          0) - 1] = c9_iidx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", (int32_T)c9_c_k,
          1, c9_iidx_sizes, 1, 0) - 1];
        c9_j_a = c9_ix;
        c9_e_b = c9_vstride;
        c9_ix = c9_j_a + c9_e_b;
      }
    }

    c9_c_i = 2;
  }
}

static void c9_b_eml_int_forloop_overflow_check
  (SFc9_WorkstationModelInstanceStruct *chartInstance, int32_T c9_b)
{
  int32_T c9_b_b;
  boolean_T c9_overflow;
  boolean_T c9_safe;
  int32_T c9_i64;
  static char_T c9_cv1[34] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'i', 'n', 't', '_', 'f', 'o', 'r', 'l', 'o', 'o', 'p',
    '_', 'o', 'v', 'e', 'r', 'f', 'l', 'o', 'w' };

  char_T c9_u[34];
  const mxArray *c9_y = NULL;
  int32_T c9_i65;
  static char_T c9_cv2[5] = { 'i', 'n', 't', '3', '2' };

  char_T c9_b_u[5];
  const mxArray *c9_b_y = NULL;
  c9_b_b = c9_b;
  if (1 > c9_b_b) {
    c9_overflow = FALSE;
  } else {
    c9_overflow = (c9_b_b > 2147483646);
  }

  c9_safe = !c9_overflow;
  if (c9_safe) {
  } else {
    for (c9_i64 = 0; c9_i64 < 34; c9_i64++) {
      c9_u[c9_i64] = c9_cv1[c9_i64];
    }

    c9_y = NULL;
    sf_mex_assign(&c9_y, sf_mex_create("y", c9_u, 10, 0U, 1U, 0U, 2, 1, 34),
                  FALSE);
    for (c9_i65 = 0; c9_i65 < 5; c9_i65++) {
      c9_b_u[c9_i65] = c9_cv2[c9_i65];
    }

    c9_b_y = NULL;
    sf_mex_assign(&c9_b_y, sf_mex_create("y", c9_b_u, 10, 0U, 1U, 0U, 2, 1, 5),
                  FALSE);
    sf_mex_call_debug("error", 0U, 1U, 14, sf_mex_call_debug("message", 1U, 2U,
      14, c9_y, 14, c9_b_y));
  }
}

static void c9_c_eml_int_forloop_overflow_check
  (SFc9_WorkstationModelInstanceStruct *chartInstance, int32_T c9_a)
{
}

static void c9_eml_sort_idx(SFc9_WorkstationModelInstanceStruct *chartInstance,
  real_T c9_x_data[4], int32_T c9_x_sizes[1], int32_T c9_idx_data[4], int32_T
  c9_idx_sizes[1])
{
  real_T c9_d5;
  int32_T c9_i66;
  int32_T c9_n;
  real_T c9_dv3[2];
  int32_T c9_idx0_sizes;
  int32_T c9_loop_ub;
  int32_T c9_i67;
  int32_T c9_idx0_data[4];
  int32_T c9_a;
  int32_T c9_np1;
  int32_T c9_k;
  int32_T c9_b_k;
  int32_T c9_c_k;
  int32_T c9_b_a;
  int32_T c9_i68;
  int32_T c9_d_k;
  int32_T c9_c_a;
  int32_T c9_c;
  int32_T c9_irow1;
  int32_T c9_irow2;
  real_T c9_d_a;
  real_T c9_b;
  real_T c9_e_a;
  real_T c9_b_b;
  boolean_T c9_p;
  real_T c9_x;
  boolean_T c9_c_b;
  boolean_T c9_b7;
  boolean_T c9_b_p;
  int32_T c9_f_a;
  int32_T c9_b_c;
  int32_T c9_g_a;
  int32_T c9_c_c;
  int32_T c9_b_loop_ub;
  int32_T c9_i69;
  int32_T c9_i;
  int32_T c9_h_a;
  int32_T c9_i2;
  int32_T c9_j;
  int32_T c9_d_b;
  int32_T c9_pEnd;
  int32_T c9_c_p;
  int32_T c9_q;
  int32_T c9_i_a;
  int32_T c9_e_b;
  int32_T c9_qEnd;
  int32_T c9_j_a;
  int32_T c9_f_b;
  int32_T c9_kEnd;
  int32_T c9_b_irow1;
  int32_T c9_b_irow2;
  real_T c9_k_a;
  real_T c9_g_b;
  real_T c9_l_a;
  real_T c9_h_b;
  boolean_T c9_d_p;
  real_T c9_b_x;
  boolean_T c9_i_b;
  boolean_T c9_b8;
  boolean_T c9_e_p;
  int32_T c9_m_a;
  int32_T c9_n_a;
  int32_T c9_o_a;
  int32_T c9_p_a;
  int32_T c9_q_a;
  int32_T c9_r_a;
  int32_T c9_s_a;
  int32_T c9_t_a;
  int32_T c9_e_k;
  int32_T c9_u_a;
  int32_T c9_j_b;
  int32_T c9_d_c;
  int32_T c9_v_a;
  int32_T c9_k_b;
  boolean_T guard1 = FALSE;
  boolean_T guard2 = FALSE;
  c9_d5 = muDoubleScalarRound((real_T)c9_x_sizes[0]);
  if (c9_d5 < 2.147483648E+9) {
    if (c9_d5 >= -2.147483648E+9) {
      c9_i66 = (int32_T)c9_d5;
    } else {
      c9_i66 = MIN_int32_T;
    }
  } else if (c9_d5 >= 2.147483648E+9) {
    c9_i66 = MAX_int32_T;
  } else {
    c9_i66 = 0;
  }

  c9_n = c9_i66;
  c9_dv3[0] = (real_T)c9_x_sizes[0];
  c9_dv3[1] = 1.0;
  c9_idx0_sizes = (int32_T)c9_dv3[0];
  c9_loop_ub = (int32_T)c9_dv3[0] - 1;
  for (c9_i67 = 0; c9_i67 <= c9_loop_ub; c9_i67++) {
    c9_idx0_data[c9_i67] = 0;
  }

  c9_idx_sizes[0] = c9_idx0_sizes;
  c9_a = c9_n + 1;
  c9_np1 = c9_a;
  if (c9_x_sizes[0] == 0) {
    c9_b_eml_int_forloop_overflow_check(chartInstance, c9_n);
    for (c9_k = 1; c9_k <= c9_n; c9_k++) {
      c9_b_k = c9_k;
      c9_idx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_b_k, 1, c9_idx_sizes[0], 1,
        0) - 1] = c9_b_k;
    }
  } else {
    c9_b_eml_int_forloop_overflow_check(chartInstance, c9_n);
    for (c9_c_k = 1; c9_c_k <= c9_n; c9_c_k++) {
      c9_b_k = c9_c_k;
      c9_idx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_b_k, 1, c9_idx_sizes[0], 1,
        0) - 1] = c9_b_k;
    }

    c9_b_a = c9_n - 1;
    c9_i68 = c9_b_a;
    c9_d_eml_int_forloop_overflow_check(chartInstance, c9_i68);
    for (c9_d_k = 1; c9_d_k <= c9_i68; c9_d_k += 2) {
      c9_b_k = c9_d_k;
      c9_c_a = c9_b_k;
      c9_c = c9_c_a;
      c9_irow1 = c9_b_k;
      c9_irow2 = c9_c + 1;
      c9_d_a = c9_x_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_irow1, 1,
        c9_x_sizes[0], 1, 0) - 1];
      c9_b = c9_x_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_irow2, 1, c9_x_sizes[0],
        1, 0) - 1];
      c9_e_a = c9_d_a;
      c9_b_b = c9_b;
      c9_p = (c9_e_a <= c9_b_b);
      guard2 = FALSE;
      if (c9_p) {
        guard2 = TRUE;
      } else {
        c9_x = c9_b;
        c9_c_b = muDoubleScalarIsNaN(c9_x);
        if (c9_c_b) {
          guard2 = TRUE;
        } else {
          c9_b7 = FALSE;
        }
      }

      if (guard2 == TRUE) {
        c9_b7 = TRUE;
      }

      c9_b_p = c9_b7;
      if (c9_b_p) {
      } else {
        c9_f_a = c9_b_k;
        c9_b_c = c9_f_a;
        c9_idx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_b_k, 1, c9_idx_sizes[0],
          1, 0) - 1] = c9_b_c + 1;
        c9_g_a = c9_b_k;
        c9_c_c = c9_g_a;
        c9_idx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_c_c + 1, 1, c9_idx_sizes
          [0], 1, 0) - 1] = c9_b_k;
      }
    }

    c9_idx0_sizes = c9_n;
    c9_b_loop_ub = c9_n - 1;
    for (c9_i69 = 0; c9_i69 <= c9_b_loop_ub; c9_i69++) {
      c9_idx0_data[c9_i69] = 1;
    }

    c9_i = 2;
    while (c9_i < c9_n) {
      c9_h_a = c9_i;
      c9_i2 = c9_h_a << 1;
      c9_j = 1;
      c9_d_b = c9_i + 1;
      for (c9_pEnd = c9_d_b; c9_pEnd < c9_np1; c9_pEnd = c9_v_a + c9_k_b) {
        c9_c_p = c9_j;
        c9_q = c9_pEnd;
        c9_i_a = c9_j;
        c9_e_b = c9_i2;
        c9_qEnd = c9_i_a + c9_e_b;
        if (c9_qEnd > c9_np1) {
          c9_qEnd = c9_np1;
        }

        c9_b_k = 1;
        c9_j_a = c9_qEnd;
        c9_f_b = c9_j;
        c9_kEnd = c9_j_a - c9_f_b;
        while (c9_b_k <= c9_kEnd) {
          c9_b_irow1 = c9_idx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_c_p, 1,
            c9_idx_sizes[0], 1, 0) - 1];
          c9_b_irow2 = c9_idx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_q, 1,
            c9_idx_sizes[0], 1, 0) - 1];
          c9_k_a = c9_x_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_b_irow1, 1,
            c9_x_sizes[0], 1, 0) - 1];
          c9_g_b = c9_x_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_b_irow2, 1,
            c9_x_sizes[0], 1, 0) - 1];
          c9_l_a = c9_k_a;
          c9_h_b = c9_g_b;
          c9_d_p = (c9_l_a <= c9_h_b);
          guard1 = FALSE;
          if (c9_d_p) {
            guard1 = TRUE;
          } else {
            c9_b_x = c9_g_b;
            c9_i_b = muDoubleScalarIsNaN(c9_b_x);
            if (c9_i_b) {
              guard1 = TRUE;
            } else {
              c9_b8 = FALSE;
            }
          }

          if (guard1 == TRUE) {
            c9_b8 = TRUE;
          }

          c9_e_p = c9_b8;
          if (c9_e_p) {
            c9_idx0_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_b_k, 1,
              c9_idx0_sizes, 1, 0) - 1] =
              c9_idx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_c_p, 1,
              c9_idx_sizes[0], 1, 0) - 1];
            c9_m_a = c9_c_p + 1;
            c9_c_p = c9_m_a;
            if (c9_c_p == c9_pEnd) {
              while (c9_q < c9_qEnd) {
                c9_n_a = c9_b_k + 1;
                c9_b_k = c9_n_a;
                c9_idx0_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_b_k, 1,
                  c9_idx0_sizes, 1, 0) - 1] =
                  c9_idx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_q, 1,
                  c9_idx_sizes[0], 1, 0) - 1];
                c9_o_a = c9_q + 1;
                c9_q = c9_o_a;
              }
            }
          } else {
            c9_idx0_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_b_k, 1,
              c9_idx0_sizes, 1, 0) - 1] =
              c9_idx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_q, 1, c9_idx_sizes
              [0], 1, 0) - 1];
            c9_p_a = c9_q + 1;
            c9_q = c9_p_a;
            if (c9_q == c9_qEnd) {
              while (c9_c_p < c9_pEnd) {
                c9_q_a = c9_b_k + 1;
                c9_b_k = c9_q_a;
                c9_idx0_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_b_k, 1,
                  c9_idx0_sizes, 1, 0) - 1] =
                  c9_idx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_c_p, 1,
                  c9_idx_sizes[0], 1, 0) - 1];
                c9_r_a = c9_c_p + 1;
                c9_c_p = c9_r_a;
              }
            }
          }

          c9_s_a = c9_b_k + 1;
          c9_b_k = c9_s_a;
        }

        c9_t_a = c9_j;
        c9_c_p = c9_t_a;
        c9_b_eml_int_forloop_overflow_check(chartInstance, c9_kEnd);
        for (c9_e_k = 1; c9_e_k <= c9_kEnd; c9_e_k++) {
          c9_b_k = c9_e_k;
          c9_u_a = c9_c_p - 1;
          c9_j_b = c9_b_k;
          c9_d_c = c9_u_a + c9_j_b;
          c9_idx_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_d_c, 1, c9_idx_sizes[0],
            1, 0) - 1] = c9_idx0_data[_SFD_EML_ARRAY_BOUNDS_CHECK("", c9_b_k, 1,
            c9_idx0_sizes, 1, 0) - 1];
        }

        c9_j = c9_qEnd;
        c9_v_a = c9_j;
        c9_k_b = c9_i;
      }

      c9_i = c9_i2;
    }
  }
}

static void c9_d_eml_int_forloop_overflow_check
  (SFc9_WorkstationModelInstanceStruct *chartInstance, int32_T c9_b)
{
}

static const mxArray *c9_f_sf_marshallOut(void *chartInstanceVoid, void
  *c9_inData)
{
  const mxArray *c9_mxArrayOutData = NULL;
  int8_T c9_u;
  const mxArray *c9_y = NULL;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_mxArrayOutData = NULL;
  c9_u = *(int8_T *)c9_inData;
  c9_y = NULL;
  sf_mex_assign(&c9_y, sf_mex_create("y", &c9_u, 2, 0U, 0U, 0U, 0), FALSE);
  sf_mex_assign(&c9_mxArrayOutData, c9_y, FALSE);
  return c9_mxArrayOutData;
}

static int8_T c9_f_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId)
{
  int8_T c9_y;
  int8_T c9_i70;
  sf_mex_import(c9_parentId, sf_mex_dup(c9_u), &c9_i70, 1, 2, 0U, 0, 0U, 0);
  c9_y = c9_i70;
  sf_mex_destroy(&c9_u);
  return c9_y;
}

static void c9_e_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c9_mxArrayInData, const char_T *c9_varName, void *c9_outData)
{
  const mxArray *c9_ServerAvailable;
  const char_T *c9_identifier;
  emlrtMsgIdentifier c9_thisId;
  int8_T c9_y;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_ServerAvailable = sf_mex_dup(c9_mxArrayInData);
  c9_identifier = c9_varName;
  c9_thisId.fIdentifier = c9_identifier;
  c9_thisId.fParent = NULL;
  c9_y = c9_f_emlrt_marshallIn(chartInstance, sf_mex_dup(c9_ServerAvailable),
    &c9_thisId);
  sf_mex_destroy(&c9_ServerAvailable);
  *(int8_T *)c9_outData = c9_y;
  sf_mex_destroy(&c9_mxArrayInData);
}

static const mxArray *c9_g_sf_marshallOut(void *chartInstanceVoid, void
  *c9_inData)
{
  const mxArray *c9_mxArrayOutData = NULL;
  int32_T c9_u;
  const mxArray *c9_y = NULL;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_mxArrayOutData = NULL;
  c9_u = *(int32_T *)c9_inData;
  c9_y = NULL;
  sf_mex_assign(&c9_y, sf_mex_create("y", &c9_u, 6, 0U, 0U, 0U, 0), FALSE);
  sf_mex_assign(&c9_mxArrayOutData, c9_y, FALSE);
  return c9_mxArrayOutData;
}

static int32_T c9_g_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId)
{
  int32_T c9_y;
  int32_T c9_i71;
  sf_mex_import(c9_parentId, sf_mex_dup(c9_u), &c9_i71, 1, 6, 0U, 0, 0U, 0);
  c9_y = c9_i71;
  sf_mex_destroy(&c9_u);
  return c9_y;
}

static void c9_f_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c9_mxArrayInData, const char_T *c9_varName, void *c9_outData)
{
  const mxArray *c9_b_sfEvent;
  const char_T *c9_identifier;
  emlrtMsgIdentifier c9_thisId;
  int32_T c9_y;
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)chartInstanceVoid;
  c9_b_sfEvent = sf_mex_dup(c9_mxArrayInData);
  c9_identifier = c9_varName;
  c9_thisId.fIdentifier = c9_identifier;
  c9_thisId.fParent = NULL;
  c9_y = c9_g_emlrt_marshallIn(chartInstance, sf_mex_dup(c9_b_sfEvent),
    &c9_thisId);
  sf_mex_destroy(&c9_b_sfEvent);
  *(int32_T *)c9_outData = c9_y;
  sf_mex_destroy(&c9_mxArrayInData);
}

static uint8_T c9_h_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_b_is_active_c9_WorkstationModel, const
  char_T *c9_identifier)
{
  uint8_T c9_y;
  emlrtMsgIdentifier c9_thisId;
  c9_thisId.fIdentifier = c9_identifier;
  c9_thisId.fParent = NULL;
  c9_y = c9_i_emlrt_marshallIn(chartInstance, sf_mex_dup
    (c9_b_is_active_c9_WorkstationModel), &c9_thisId);
  sf_mex_destroy(&c9_b_is_active_c9_WorkstationModel);
  return c9_y;
}

static uint8_T c9_i_emlrt_marshallIn(SFc9_WorkstationModelInstanceStruct
  *chartInstance, const mxArray *c9_u, const emlrtMsgIdentifier *c9_parentId)
{
  uint8_T c9_y;
  uint8_T c9_u0;
  sf_mex_import(c9_parentId, sf_mex_dup(c9_u), &c9_u0, 1, 3, 0U, 0, 0U, 0);
  c9_y = c9_u0;
  sf_mex_destroy(&c9_u);
  return c9_y;
}

static void init_dsm_address_info(SFc9_WorkstationModelInstanceStruct
  *chartInstance)
{
}

/* SFunction Glue Code */
void sf_c9_WorkstationModel_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(740631358U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(3151491081U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(4202941493U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(4266386326U);
}

mxArray *sf_c9_WorkstationModel_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs", "locals" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1,1,5,
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateString("p2QZ8ypMjQ3A7I6UdWwL8G");
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,4,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(4);
      pr[1] = (double)(1);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(4);
      pr[1] = (double)(1);
      mxSetField(mxData,1,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,1,"type",mxType);
    }

    mxSetField(mxData,1,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(2);
      pr[1] = (double)(1);
      mxSetField(mxData,2,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,2,"type",mxType);
    }

    mxSetField(mxData,2,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(2);
      pr[1] = (double)(1);
      mxSetField(mxData,3,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,3,"type",mxType);
    }

    mxSetField(mxData,3,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"inputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"parameters",mxCreateDoubleMatrix(0,0,
                mxREAL));
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,1,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"outputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"locals",mxCreateDoubleMatrix(0,0,mxREAL));
  }

  return(mxAutoinheritanceInfo);
}

static const mxArray *sf_get_sim_state_info_c9_WorkstationModel(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x2'type','srcId','name','auxInfo'{{M[1],M[10],T\"Resource\",},{M[8],M[0],T\"is_active_c9_WorkstationModel\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 2, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c9_WorkstationModel_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc9_WorkstationModelInstanceStruct *chartInstance;
    chartInstance = (SFc9_WorkstationModelInstanceStruct *) ((ChartInfoStruct *)
      (ssGetUserData(S)))->chartInstance;
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (_WorkstationModelMachineNumber_,
           9,
           1,
           1,
           5,
           5,
           0,
           0,
           0,
           0,
           &(chartInstance->chartNumber),
           &(chartInstance->instanceNumber),
           ssGetPath(S),
           (void *)S);
        if (chartAlreadyPresent==0) {
          /* this is the first instance */
          init_script_number_translation(_WorkstationModelMachineNumber_,
            chartInstance->chartNumber);
          sf_debug_set_chart_disable_implicit_casting
            (_WorkstationModelMachineNumber_,chartInstance->chartNumber,1);
          sf_debug_set_chart_event_thresholds(_WorkstationModelMachineNumber_,
            chartInstance->chartNumber,
            5,
            5,
            5);
          _SFD_SET_DATA_PROPS(0,1,1,0,"LongestWaitTime");
          _SFD_SET_DATA_PROPS(1,1,1,0,"ProcessTime");
          _SFD_SET_DATA_PROPS(2,1,1,0,"ResourceAvailability");
          _SFD_SET_DATA_PROPS(3,1,1,0,"ResourceProductionState");
          _SFD_SET_DATA_PROPS(4,2,0,1,"Resource");
          _SFD_EVENT_SCOPE(0,1);
          _SFD_EVENT_SCOPE(1,2);
          _SFD_EVENT_SCOPE(2,2);
          _SFD_EVENT_SCOPE(3,2);
          _SFD_EVENT_SCOPE(4,2);
          _SFD_STATE_INFO(0,0,2);
          _SFD_CH_SUBSTATE_COUNT(0);
          _SFD_CH_SUBSTATE_DECOMP(0);
        }

        _SFD_CV_INIT_CHART(0,0,0,0);

        {
          _SFD_CV_INIT_STATE(0,0,0,0,0,0,NULL,NULL);
        }

        _SFD_CV_INIT_TRANS(0,0,NULL,NULL,0,NULL);

        /* Initialization of MATLAB Function Model Coverage */
        _SFD_CV_INIT_EML(0,1,1,1,0,2,0,0,0,0);
        _SFD_CV_INIT_EML_FCN(0,0,"eML_blk_kernel",0,-1,1530);
        _SFD_CV_INIT_EML_IF(0,1,0,226,244,-1,1525);

        {
          static int caseStart[] = { 1234, 1153, 1193 };

          static int caseExprEnd[] = { 1243, 1159, 1199 };

          _SFD_CV_INIT_EML_SWITCH(0,1,0,1116,1145,1277,3,&(caseStart[0]),
            &(caseExprEnd[0]));
        }

        {
          static int caseStart[] = { 1503, 1343, 1383, 1423, 1463 };

          static int caseExprEnd[] = { 1512, 1349, 1389, 1429, 1469 };

          _SFD_CV_INIT_EML_SWITCH(0,1,1,1319,1335,1520,5,&(caseStart[0]),
            &(caseExprEnd[0]));
        }

        _SFD_TRANS_COV_WTS(0,0,0,1,0);
        if (chartAlreadyPresent==0) {
          _SFD_TRANS_COV_MAPS(0,
                              0,NULL,NULL,
                              0,NULL,NULL,
                              1,NULL,NULL,
                              0,NULL,NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 4;
          _SFD_SET_DATA_COMPILED_PROPS(0,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c9_c_sf_marshallOut,(MexInFcnForType)NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 4;
          _SFD_SET_DATA_COMPILED_PROPS(1,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c9_c_sf_marshallOut,(MexInFcnForType)NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 2;
          _SFD_SET_DATA_COMPILED_PROPS(2,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c9_b_sf_marshallOut,(MexInFcnForType)NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 2;
          _SFD_SET_DATA_COMPILED_PROPS(3,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c9_b_sf_marshallOut,(MexInFcnForType)NULL);
        }

        _SFD_SET_DATA_COMPILED_PROPS(4,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c9_sf_marshallOut,(MexInFcnForType)c9_sf_marshallIn);

        {
          real_T *c9_Resource;
          real_T (*c9_LongestWaitTime)[4];
          real_T (*c9_ProcessTime)[4];
          real_T (*c9_ResourceAvailability)[2];
          real_T (*c9_ResourceProductionState)[2];
          c9_Resource = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
          c9_ResourceProductionState = (real_T (*)[2])ssGetInputPortSignal
            (chartInstance->S, 3);
          c9_ResourceAvailability = (real_T (*)[2])ssGetInputPortSignal
            (chartInstance->S, 2);
          c9_ProcessTime = (real_T (*)[4])ssGetInputPortSignal(chartInstance->S,
            1);
          c9_LongestWaitTime = (real_T (*)[4])ssGetInputPortSignal
            (chartInstance->S, 0);
          _SFD_SET_DATA_VALUE_PTR(0U, *c9_LongestWaitTime);
          _SFD_SET_DATA_VALUE_PTR(1U, *c9_ProcessTime);
          _SFD_SET_DATA_VALUE_PTR(2U, *c9_ResourceAvailability);
          _SFD_SET_DATA_VALUE_PTR(3U, *c9_ResourceProductionState);
          _SFD_SET_DATA_VALUE_PTR(4U, c9_Resource);
        }
      }
    } else {
      sf_debug_reset_current_state_configuration(_WorkstationModelMachineNumber_,
        chartInstance->chartNumber,chartInstance->instanceNumber);
    }
  }
}

static const char* sf_get_instance_specialization()
{
  return "niSLmUvDIhNDe9l4wBlR4B";
}

static void sf_opaque_initialize_c9_WorkstationModel(void *chartInstanceVar)
{
  chart_debug_initialization(((SFc9_WorkstationModelInstanceStruct*)
    chartInstanceVar)->S,0);
  initialize_params_c9_WorkstationModel((SFc9_WorkstationModelInstanceStruct*)
    chartInstanceVar);
  initialize_c9_WorkstationModel((SFc9_WorkstationModelInstanceStruct*)
    chartInstanceVar);
}

static void sf_opaque_enable_c9_WorkstationModel(void *chartInstanceVar)
{
  enable_c9_WorkstationModel((SFc9_WorkstationModelInstanceStruct*)
    chartInstanceVar);
}

static void sf_opaque_disable_c9_WorkstationModel(void *chartInstanceVar)
{
  disable_c9_WorkstationModel((SFc9_WorkstationModelInstanceStruct*)
    chartInstanceVar);
}

static void sf_opaque_gateway_c9_WorkstationModel(void *chartInstanceVar)
{
  sf_c9_WorkstationModel((SFc9_WorkstationModelInstanceStruct*) chartInstanceVar);
}

extern const mxArray* sf_internal_get_sim_state_c9_WorkstationModel(SimStruct* S)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_raw2high");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = (mxArray*) get_sim_state_c9_WorkstationModel
    ((SFc9_WorkstationModelInstanceStruct*)chartInfo->chartInstance);/* raw sim ctx */
  prhs[3] = (mxArray*) sf_get_sim_state_info_c9_WorkstationModel();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  mxDestroyArray(prhs[3]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_raw2high'.\n");
  }

  return plhs[0];
}

extern void sf_internal_set_sim_state_c9_WorkstationModel(SimStruct* S, const
  mxArray *st)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_high2raw");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = mxDuplicateArray(st);      /* high level simctx */
  prhs[3] = (mxArray*) sf_get_sim_state_info_c9_WorkstationModel();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  mxDestroyArray(prhs[3]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_high2raw'.\n");
  }

  set_sim_state_c9_WorkstationModel((SFc9_WorkstationModelInstanceStruct*)
    chartInfo->chartInstance, mxDuplicateArray(plhs[0]));
  mxDestroyArray(plhs[0]);
}

static const mxArray* sf_opaque_get_sim_state_c9_WorkstationModel(SimStruct* S)
{
  return sf_internal_get_sim_state_c9_WorkstationModel(S);
}

static void sf_opaque_set_sim_state_c9_WorkstationModel(SimStruct* S, const
  mxArray *st)
{
  sf_internal_set_sim_state_c9_WorkstationModel(S, st);
}

static void sf_opaque_terminate_c9_WorkstationModel(void *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc9_WorkstationModelInstanceStruct*) chartInstanceVar)->S;
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
    }

    finalize_c9_WorkstationModel((SFc9_WorkstationModelInstanceStruct*)
      chartInstanceVar);
    free((void *)chartInstanceVar);
    ssSetUserData(S,NULL);
  }

  unload_WorkstationModel_optimization_info();
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  initSimStructsc9_WorkstationModel((SFc9_WorkstationModelInstanceStruct*)
    chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c9_WorkstationModel(SimStruct *S)
{
  int i;
  for (i=0;i<ssGetNumRunTimeParams(S);i++) {
    if (ssGetSFcnParamTunable(S,i)) {
      ssUpdateDlgParamAsRunTimeParam(S,i);
    }
  }

  if (sf_machine_global_initializer_called()) {
    initialize_params_c9_WorkstationModel((SFc9_WorkstationModelInstanceStruct*)
      (((ChartInfoStruct *)ssGetUserData(S))->chartInstance));
  }
}

static void mdlSetWorkWidths_c9_WorkstationModel(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    mxArray *infoStruct = load_WorkstationModel_optimization_info();
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(S,sf_get_instance_specialization(),infoStruct,
      9);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,sf_rtw_info_uint_prop(S,sf_get_instance_specialization(),
                infoStruct,9,"RTWCG"));
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop(S,
      sf_get_instance_specialization(),infoStruct,9,
      "gatewayCannotBeInlinedMultipleTimes"));
    sf_mark_output_events_with_multiple_callers(S,sf_get_instance_specialization
      (),infoStruct,9,4);
    if (chartIsInlinable) {
      ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 2, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 3, SS_REUSABLE_AND_LOCAL);
      sf_mark_chart_expressionable_inputs(S,sf_get_instance_specialization(),
        infoStruct,9,4);
      sf_mark_chart_reusable_outputs(S,sf_get_instance_specialization(),
        infoStruct,9,1);
    }

    ssSetInputPortOptimOpts(S, 4, SS_REUSABLE_AND_LOCAL);
    sf_set_rtw_dwork_info(S,sf_get_instance_specialization(),infoStruct,9);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(3986296787U));
  ssSetChecksum1(S,(3382591431U));
  ssSetChecksum2(S,(1323995319U));
  ssSetChecksum3(S,(2780015663U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
}

static void mdlRTW_c9_WorkstationModel(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");
  }
}

static void mdlStart_c9_WorkstationModel(SimStruct *S)
{
  SFc9_WorkstationModelInstanceStruct *chartInstance;
  chartInstance = (SFc9_WorkstationModelInstanceStruct *)malloc(sizeof
    (SFc9_WorkstationModelInstanceStruct));
  memset(chartInstance, 0, sizeof(SFc9_WorkstationModelInstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 1;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway =
    sf_opaque_gateway_c9_WorkstationModel;
  chartInstance->chartInfo.initializeChart =
    sf_opaque_initialize_c9_WorkstationModel;
  chartInstance->chartInfo.terminateChart =
    sf_opaque_terminate_c9_WorkstationModel;
  chartInstance->chartInfo.enableChart = sf_opaque_enable_c9_WorkstationModel;
  chartInstance->chartInfo.disableChart = sf_opaque_disable_c9_WorkstationModel;
  chartInstance->chartInfo.getSimState =
    sf_opaque_get_sim_state_c9_WorkstationModel;
  chartInstance->chartInfo.setSimState =
    sf_opaque_set_sim_state_c9_WorkstationModel;
  chartInstance->chartInfo.getSimStateInfo =
    sf_get_sim_state_info_c9_WorkstationModel;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c9_WorkstationModel;
  chartInstance->chartInfo.mdlStart = mdlStart_c9_WorkstationModel;
  chartInstance->chartInfo.mdlSetWorkWidths =
    mdlSetWorkWidths_c9_WorkstationModel;
  chartInstance->chartInfo.extModeExec = NULL;
  chartInstance->chartInfo.restoreLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.restoreBeforeLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.storeCurrentConfiguration = NULL;
  chartInstance->S = S;
  ssSetUserData(S,(void *)(&(chartInstance->chartInfo)));/* register the chart instance with simstruct */
  init_dsm_address_info(chartInstance);
  if (!sim_mode_is_rtw_gen(S)) {
  }

  sf_opaque_init_subchart_simstructs(chartInstance->chartInfo.chartInstance);
  chart_debug_initialization(S,1);
}

void c9_WorkstationModel_method_dispatcher(SimStruct *S, int_T method, void
  *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c9_WorkstationModel(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c9_WorkstationModel(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c9_WorkstationModel(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c9_WorkstationModel_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}
