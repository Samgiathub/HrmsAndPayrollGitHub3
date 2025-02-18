using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095Increment
{
    public decimal IncrementId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? CatId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? BankId { get; set; }

    public decimal? CurrId { get; set; }

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

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? YearlyBonusAmount { get; set; }

    public DateTime? DeputationEndDate { get; set; }

    public byte? IsDeputationReminder { get; set; }

    public decimal? ApprIntId { get; set; }

    public decimal? Ctc { get; set; }

    public decimal? EmpEarlyMark { get; set; }

    public string? EarlyDeduType { get; set; }

    public string? EmpEarlyLimit { get; set; }

    public decimal? EmpDeficitMark { get; set; }

    public string? DeficitDeduType { get; set; }

    public string? EmpDeficitLimit { get; set; }

    public decimal? CenterId { get; set; }

    public decimal? EmpWeekDayOtRate { get; set; }

    public decimal? EmpWeekOffOtRate { get; set; }

    public decimal? EmpHolidayOtRate { get; set; }

    public byte IsMetroCity { get; set; }

    public decimal PreCtcSalary { get; set; }

    public decimal IncermentAmountGross { get; set; }

    public decimal IncermentAmountCtc { get; set; }

    public byte IncrementMode { get; set; }

    public byte? IsPhysical { get; set; }

    public decimal? SalDateId { get; set; }

    public byte EmpAutoVpf { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? SubBranchId { get; set; }

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

    public byte CustomerAudit { get; set; }

    public decimal? IncrementAppId { get; set; }

    public string? SalesCode { get; set; }

    public decimal PhysicalPercent { get; set; }

    public byte? IsPieceTransSalary { get; set; }

    public decimal? BandId { get; set; }

    public bool? IsPradhanMantri { get; set; }

    public bool? Is1timePfMember { get; set; }

    public string? Remarks { get; set; }

    public bool? FullPension { get; set; }

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();

    public virtual ICollection<T0095EmpSchema> T0095EmpSchemas { get; set; } = new List<T0095EmpSchema>();

    public virtual ICollection<T0100EmpEarnDeduction> T0100EmpEarnDeductions { get; set; } = new List<T0100EmpEarnDeduction>();

    public virtual ICollection<T0100EmpManagerHistory> T0100EmpManagerHistories { get; set; } = new List<T0100EmpManagerHistory>();

    public virtual ICollection<T0120ArApproval> T0120ArApprovals { get; set; } = new List<T0120ArApproval>();

    public virtual ICollection<T0200MonthlySalary> T0200MonthlySalaries { get; set; } = new List<T0200MonthlySalary>();

    public virtual ICollection<T0200MonthlySalaryDaily> T0200MonthlySalaryDailies { get; set; } = new List<T0200MonthlySalaryDaily>();

    public virtual ICollection<T0200MonthlySalaryLeave> T0200MonthlySalaryLeaves { get; set; } = new List<T0200MonthlySalaryLeave>();

    public virtual ICollection<T0201MonthlySalarySett> T0201MonthlySalarySetts { get; set; } = new List<T0201MonthlySalarySett>();
}
