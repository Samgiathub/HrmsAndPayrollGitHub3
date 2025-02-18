using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140TravelSattlementApprovalDetailUpdate
{
    public decimal IntId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal Amount { get; set; }

    public string ExpenseTypeName { get; set; } = null!;

    public string? Comments { get; set; }

    public byte? Missing { get; set; }

    public decimal IntExpId { get; set; }

    public decimal TravelSettlementId { get; set; }

    public decimal? ApprovedAmount { get; set; }

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public decimal Duration { get; set; }

    public string? ApprFromTime { get; set; }

    public string? ApprToTime { get; set; }

    public decimal ApprDuration { get; set; }

    public decimal TravelAllowance { get; set; }

    public decimal LimitAmnt { get; set; }

    public string? GrpEmp { get; set; }

    public string? GrpEmpId { get; set; }

    public decimal CurrId { get; set; }

    public string Currency { get; set; } = null!;

    public decimal ExchangeRate { get; set; }

    public decimal DiffAmount { get; set; }

    public decimal ExpKm { get; set; }

    public byte IsPetrol { get; set; }

    public decimal RateKm { get; set; }

    public string FileName { get; set; } = null!;

    public string? FileNameOriginal { get; set; }

    public string StrRate { get; set; } = null!;

    public decimal ExpAmount { get; set; }

    public decimal CityId { get; set; }

    public string CityName { get; set; } = null!;

    public decimal TravelModeId { get; set; }

    public string ModeName { get; set; } = null!;

    public decimal CmpId { get; set; }

    public byte GstApplicable { get; set; }

    public decimal Sgst { get; set; }

    public decimal Cgst { get; set; }

    public decimal Igst { get; set; }

    public string? GstNo { get; set; }

    public string? GstCompanyName { get; set; }

    public int? TravelMode { get; set; }

    public decimal TravelSetApplicationId { get; set; }

    public byte SelfPay { get; set; }

    public decimal NoOfDays { get; set; }

    public string? GuestName { get; set; }
}
