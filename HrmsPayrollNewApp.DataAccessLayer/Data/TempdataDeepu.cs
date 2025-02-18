using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TempdataDeepu
{
    public DateTime? EffectiveDate { get; set; }

    public decimal? Slabid { get; set; }

    public string? CostSlabName { get; set; }

    public decimal? BandId { get; set; }

    public string? BandName { get; set; }

    public decimal? SegmentId { get; set; }

    public string? SegmentName { get; set; }

    public decimal? CenterId { get; set; }

    public string? CenterName { get; set; }

    public decimal? CostAmount { get; set; }
}
