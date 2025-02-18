using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0070EmpIncrementApp
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int IncrementId { get; set; }

    public int CmpId { get; set; }

    public int BranchId { get; set; }

    public int? CatId { get; set; }

    public int GrdId { get; set; }

    public int? DeptId { get; set; }

    public int? DesigId { get; set; }

    public int? TypeId { get; set; }

    public int? BankId { get; set; }

    public int? CurrId { get; set; }

    public string? WagesType { get; set; }

    public string? SalaryBasisOn { get; set; }

    public decimal? BasicSalary { get; set; }

    public decimal? GrossSalary { get; set; }

    public string? IncrementType { get; set; }

    public DateTime IncrementDate { get; set; }

    public DateTime IncrementEffectiveDate { get; set; }

    public string? PaymentMode { get; set; }

    public string? IncBankAcNo { get; set; }

    public decimal? EmpOt { get; set; }

    public string? EmpOtMinLimit { get; set; }

    public string? EmpOtMaxLimit { get; set; }

    public decimal? IncrementPer { get; set; }

    public decimal? IncrementAmount { get; set; }

    public decimal? PreBasicSalary { get; set; }

    public decimal? PreGrossSalary { get; set; }

    public string? IncrementComments { get; set; }

    public decimal? EmpLateMark { get; set; }

    public decimal? EmpFullPf { get; set; }

    public decimal? EmpPt { get; set; }

    public decimal? EmpFixSalary { get; set; }

    public byte? EmpPartTime { get; set; }

    public string? LateDeduType { get; set; }

    public string? EmpLateLimit { get; set; }

    public decimal? EmpPtAmount { get; set; }

    public byte? EmpChildran { get; set; }

    public byte? IsMasterRec { get; set; }

    public int? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? YearlyBonusAmount { get; set; }

    public DateTime? DeputationEndDate { get; set; }

    public byte? IsDeputationReminder { get; set; }

    public int? ApprIntId { get; set; }

    public decimal? Ctc { get; set; }

    public decimal? EmpEarlyMark { get; set; }

    public string? EarlyDeduType { get; set; }

    public string? EmpEarlyLimit { get; set; }

    public decimal? EmpDeficitMark { get; set; }

    public string? DeficitDeduType { get; set; }

    public string? EmpDeficitLimit { get; set; }

    public int? CenterId { get; set; }

    public decimal? EmpWeekDayOtRate { get; set; }

    public decimal? EmpWeekOffOtRate { get; set; }

    public decimal? EmpHolidayOtRate { get; set; }

    public byte IsMetroCity { get; set; }

    public decimal PreCtcSalary { get; set; }

    public decimal IncermentAmountGross { get; set; }

    public decimal IncermentAmountCtc { get; set; }

    public byte IncrementMode { get; set; }

    public byte? IsPhysical { get; set; }

    public int? SalDateId { get; set; }

    public byte EmpAutoVpf { get; set; }

    public int? SegmentId { get; set; }

    public int? VerticalId { get; set; }

    public int? SubVerticalId { get; set; }

    public int? SubBranchId { get; set; }

    public byte MonthlyDeficitAdjustOtHrs { get; set; }

    public decimal FixOtHourRateWd { get; set; }

    public decimal FixOtHourRateWoHo { get; set; }

    public decimal? BankIdTwo { get; set; }

    public string? PaymentModeTwo { get; set; }

    public string? IncBankAcNoTwo { get; set; }

    public string? BankBranchName { get; set; }

    public string? BankBranchNameTwo { get; set; }

    public decimal ReasonId { get; set; }

    public string? ReasonName { get; set; }

    public int? IncrementAppId { get; set; }

    public byte CustomerAudit { get; set; }

    public string? SalesCode { get; set; }

    public decimal PhysicalPercent { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public int? PayScaleId { get; set; }

    public DateTime? PayScaleEffectiveDate { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
