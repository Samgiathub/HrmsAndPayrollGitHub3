using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150TravelSettlementApprovalExpense
{
    public decimal IntExpId { get; set; }

    public decimal IntId { get; set; }

    public decimal TravelSettlementId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? Amount { get; set; }

    public decimal? ApprovedAmount { get; set; }

    public decimal? ExpenseTypeId { get; set; }

    public string? Comments { get; set; }

    public byte? Missing { get; set; }

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public decimal Duration { get; set; }

    public string? ApprFromTime { get; set; }

    public string? ApprToTime { get; set; }

    public decimal ApprDuration { get; set; }

    public string? GrpEmp { get; set; }

    public string? GrpEmpId { get; set; }

    public decimal? CurrId { get; set; }

    public decimal? ExchangeRate { get; set; }

    public decimal? CurrAmount { get; set; }

    public decimal? ExpKm { get; set; }

    public byte SelfPay { get; set; }

    public decimal? NoOfDays { get; set; }

    public string? GuestName { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
