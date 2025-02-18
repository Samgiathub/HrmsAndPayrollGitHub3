using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080EmpTravelProof
{
    public decimal TrackingId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string ImageName { get; set; } = null!;

    public string ImagePath { get; set; } = null!;

    public int TravelProofType { get; set; }

    public decimal? TravelAppCode { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string? TravelMode { get; set; }
}
