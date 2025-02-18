using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SumcheckSum
{
    public long? SrNo { get; set; }

    public string? EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? Branch { get; set; }

    public string? BranchState { get; set; }

    public string? VerticalName { get; set; }

    public string? SubverticalName { get; set; }

    public string? Department { get; set; }

    public string? Designation { get; set; }

    public string? Grade { get; set; }

    public string? BandName { get; set; }

    public string? TypeName { get; set; }

    public string? CostCenter { get; set; }

    public string? CenterCode { get; set; }

    public string? CostElement { get; set; }

    public string? Category { get; set; }

    public string? SubbranchName { get; set; }

    public string? SegmentName { get; set; }

    public decimal? EnrollNo { get; set; }

    public string? JoiningDate { get; set; }

    public string LeftDate { get; set; } = null!;

    public string? PanNo { get; set; }

    public string? AadharCardNo { get; set; }

    public string? DateOfBirth { get; set; }

    public string? MobileNo { get; set; }

    public string? OfficialEmail { get; set; }

    public decimal MonthDays { get; set; }

    public decimal PresentDay { get; set; }

    public decimal? AbsentDay { get; set; }

    public decimal HolidayDay { get; set; }

    public decimal WeekoffDay { get; set; }

    public decimal? TotalPaidLeaveDays { get; set; }

    public int Unpaid { get; set; }

    public decimal? TotalLeaveDays { get; set; }

    public decimal? LateDays { get; set; }

    public decimal? EarlyDays { get; set; }

    public decimal SalCalDay { get; set; }

    public decimal? ArearDay { get; set; }

    public decimal? ArearDayMonth { get; set; }

    public decimal PresentOnHoliday { get; set; }

    public decimal? BasicActual { get; set; }

    public int TotalActual { get; set; }

    public decimal? GrossSalaryActual { get; set; }

    public int NonGrossSalaryActual { get; set; }

    public int TotalAutoPaidSalaryActual { get; set; }

    public decimal? CtcActual { get; set; }

    public decimal? PtAmountActual { get; set; }

    public int DeductionActual { get; set; }

    public decimal? TotalDeductionActual { get; set; }

    public decimal? NetAmountActual { get; set; }

    public decimal? BasicSalary { get; set; }

    public decimal SettlSalary { get; set; }

    public decimal? OtherAllow { get; set; }

    public int OtherEarnings { get; set; }

    public decimal? TotalEarning { get; set; }

    public decimal? BasicSalaryArrear { get; set; }

    public int Arears { get; set; }

    public decimal? TotalArrearEarning { get; set; }

    public decimal HolidayOtHours { get; set; }

    public decimal HolidayOtAmount { get; set; }

    public decimal WeekoffOtHours { get; set; }

    public decimal WeekoffOtAmount { get; set; }

    public decimal? OtRate { get; set; }

    public decimal OtHours { get; set; }

    public decimal OtAmount { get; set; }

    public decimal WeekDayFixOtRate { get; set; }

    public decimal WoHoFixOtRate { get; set; }

    public decimal GradeOtHours { get; set; }

    public decimal LeaveEncashAmount { get; set; }

    public decimal TravelAmount { get; set; }

    public decimal TotalClaimAmount { get; set; }

    public decimal UniformRefundAmount { get; set; }

    public decimal? GrossSalary { get; set; }

    public decimal? PtAmount { get; set; }

    public int LoanAmount { get; set; }

    public decimal BondAmount { get; set; }

    public decimal AdvanceAmount { get; set; }

    public decimal OtherDeduction { get; set; }

    public decimal? RevenueAmount { get; set; }

    public decimal LwfAmount { get; set; }

    public decimal OtherDedu { get; set; }

    public decimal GatePassAmount { get; set; }

    public decimal AssetInstallmentAmount { get; set; }

    public decimal UniformInstallmentAmount { get; set; }

    public decimal LateDeduAmount { get; set; }

    public decimal? TotalDeduction { get; set; }

    public int ArearDeduction { get; set; }

    public int TotalArrearDeduction { get; set; }

    public decimal? NetTotalDeduction { get; set; }

    public decimal? NetSalary { get; set; }

    public decimal NetRound { get; set; }

    public decimal TravelAdvanceAmount { get; set; }

    public decimal? TotalNet { get; set; }

    public int OtherPartOfCtc { get; set; }

    public int EmployerPfContributionArear { get; set; }

    public int TotalEmpContribution { get; set; }

    public decimal? TotalCtcSalary { get; set; }

    public int OtherAllowanceC { get; set; }

    public string? SalaryStatus { get; set; }

    public string? PaymentMode { get; set; }

    public string? BankName { get; set; }

    public string? IncBankAcNo { get; set; }

    public string? BankBranchName { get; set; }

    public string? BankIfscCode { get; set; }

    public string? UanNo { get; set; }

    public string? EsicNo { get; set; }

    public string? PfNo { get; set; }

    public decimal? DesigDisNo { get; set; }

    public string? Gender { get; set; }

    public decimal? PfWages { get; set; }

    public decimal? EsiWages { get; set; }

    public string? Qualification { get; set; }

    public string? MaritalStatus { get; set; }

    public string? MonthYear { get; set; }
}
