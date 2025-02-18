using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040PayScaleMaster
{
    public decimal PayScaleId { get; set; }

    public decimal? CmpId { get; set; }

    public string? PayScaleName { get; set; }

    public string? PayScaleDetail { get; set; }

    public DateTime? Systemdate { get; set; }
}
