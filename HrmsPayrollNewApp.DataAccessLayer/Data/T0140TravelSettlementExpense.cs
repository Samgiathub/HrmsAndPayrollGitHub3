using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140TravelSettlementExpense
{
    public decimal IntId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? Amount { get; set; }

    public decimal? ExpenseTypeId { get; set; }

    public string? Comments { get; set; }

    public byte? Missing { get; set; }

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public decimal Duration { get; set; }

    public decimal? TravelAllowance { get; set; }

    public decimal? LimitAmount { get; set; }

    public string? GrpEmp { get; set; }

    public string? GrpEmpId { get; set; }

    public decimal OverlimitExpense { get; set; }

    public decimal? CurrId { get; set; }

    public decimal? ExchangeRate { get; set; }

    public decimal? DiffAmount { get; set; }

    public byte IsPetrol { get; set; }

    public decimal? ExpKm { get; set; }

    public decimal? RateKm { get; set; }

    public string? FileName { get; set; }

    public decimal? CityId { get; set; }

    public decimal? TravelModeId { get; set; }

    public decimal? TravelSetApplicationId { get; set; }

    public decimal Sgst { get; set; }

    public decimal Cgst { get; set; }

    public decimal Igst { get; set; }

    public string? GstNo { get; set; }

    public string? GstCompanyName { get; set; }

    public byte SelfPay { get; set; }

    public decimal NoOfDays { get; set; }

    public string? GuestName { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
