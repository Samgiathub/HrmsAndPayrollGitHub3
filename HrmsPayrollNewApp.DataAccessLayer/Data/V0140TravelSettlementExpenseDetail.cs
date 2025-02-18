using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140TravelSettlementExpenseDetail
{
    public decimal IntId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? Amount { get; set; }

    public string ExpenseTypeName { get; set; } = null!;

    public string? Comments { get; set; }

    public byte? Missing { get; set; }

    public int IntExpId { get; set; }

    public int TravelSettlementId { get; set; }

    public int ApprovedAmount { get; set; }

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public decimal Duration { get; set; }

    public string ApprFromTime { get; set; } = null!;

    public string ApprToTime { get; set; } = null!;

    public string ApprDuration { get; set; } = null!;

    public decimal TravelAllowance { get; set; }

    public decimal? LimitAmnt { get; set; }

    public string? GrpEmp { get; set; }

    public string? GrpEmpId { get; set; }

    public decimal? ExpAmount { get; set; }

    public byte IsOverlimit { get; set; }

    public decimal DiffAmount { get; set; }

    public string? Currency { get; set; }

    public decimal? ExchngeRate { get; set; }

    public decimal? CurrId { get; set; }

    public decimal? ExpKm { get; set; }

    public byte IsPetrol { get; set; }

    public string? FileName { get; set; }

    public decimal RateKm { get; set; }

    public string? FileNameOriginal { get; set; }

    public decimal CityId { get; set; }

    public string CityName { get; set; } = null!;

    public decimal TravelModeId { get; set; }

    public string StrRate { get; set; } = null!;

    public string ModeName { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal? TravelSetApplicationId { get; set; }

    public byte GstApplicable { get; set; }

    public decimal Sgst { get; set; }

    public decimal Cgst { get; set; }

    public decimal Igst { get; set; }

    public string? GstNo { get; set; }

    public string? GstCompanyName { get; set; }

    public int? TravelMode { get; set; }

    public byte Selfpay { get; set; }

    public decimal? RptLevel { get; set; }

    public decimal NoOfDays { get; set; }

    public string? GuestName { get; set; }
}
