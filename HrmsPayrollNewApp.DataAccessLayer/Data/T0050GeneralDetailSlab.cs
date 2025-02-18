using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050GeneralDetailSlab
{
    public int SlabId { get; set; }

    public decimal CmpId { get; set; }

    public decimal GenId { get; set; }

    public decimal? FromHours { get; set; }

    public decimal? ToHours { get; set; }

    public decimal? DeductionDays { get; set; }

    public string SlabType { get; set; } = null!;
}
