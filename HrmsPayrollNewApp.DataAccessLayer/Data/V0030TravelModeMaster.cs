using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0030TravelModeMaster
{
    public decimal TravelModeId { get; set; }

    public decimal CmpId { get; set; }

    public string TravelModeName { get; set; } = null!;

    public string GstApplicable { get; set; } = null!;

    public string ModeType { get; set; } = null!;
}
