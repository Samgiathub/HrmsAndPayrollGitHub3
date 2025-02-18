using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0130TravelApprovalOtherDetail
{
    public decimal TravelAprOtherDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal TravelModeId { get; set; }

    public string? ForDate { get; set; }

    public string? FromTime { get; set; }

    public string? Description { get; set; }

    public decimal? Amount { get; set; }

    public string SelfPay { get; set; } = null!;

    public DateTime? ModifyDate { get; set; }

    public string TravelModeName { get; set; } = null!;

    public string? TravelAppCode { get; set; }
}
