using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050GeneralOtRateSlabwise
{
    public int TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal GenId { get; set; }

    public decimal FromHours { get; set; }

    public decimal ToHours { get; set; }

    public decimal WdRate { get; set; }

    public decimal? WoRate { get; set; }

    public decimal? HoRate { get; set; }

    public DateTime? SystemDate { get; set; }
}
