using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsRangeMultiplier
{
    public decimal MulRangeId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? MulRangeFrom { get; set; }

    public decimal? MulRangeTo { get; set; }

    public decimal? MulRangeSlab { get; set; }

    public DateTime? MulEffectiveDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? IpAddress { get; set; }
}
