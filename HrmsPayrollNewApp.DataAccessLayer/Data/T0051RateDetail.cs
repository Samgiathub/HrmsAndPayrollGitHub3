using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0051RateDetail
{
    public decimal RateDetailId { get; set; }

    public decimal? RateId { get; set; }

    public decimal? Rate { get; set; }

    public decimal? FromLimit { get; set; }

    public decimal? ToLimit { get; set; }
}
