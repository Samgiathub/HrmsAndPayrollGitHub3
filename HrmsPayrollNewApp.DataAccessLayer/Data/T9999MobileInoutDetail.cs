using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999MobileInoutDetail
{
    public decimal IoTranDetailsId { get; set; }

    public decimal? IoTranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? IoDatetime { get; set; }

    public string? ImeiNo { get; set; }

    public string? InOutFlag { get; set; }

    public string? Latitude { get; set; }

    public string? Longitude { get; set; }

    public string? Location { get; set; }

    public string? EmpImage { get; set; }

    public string? Reason { get; set; }

    public decimal ApprovalStatus { get; set; }

    public decimal? ApprovalBy { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public decimal ApprovalFromMobile { get; set; }

    public int? IsVerify { get; set; }

    public byte IsOffline { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public string? ManagerComment { get; set; }

    public decimal? REmpId { get; set; }
}
