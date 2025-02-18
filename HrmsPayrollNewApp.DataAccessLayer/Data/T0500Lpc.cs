using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0500Lpc
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public string? ClientCode { get; set; }

    public string? EmpCode { get; set; }

    public decimal? RateOfInterest { get; set; }

    public decimal? LpcMonth { get; set; }

    public decimal? LpcYear { get; set; }

    public decimal? UserId { get; set; }

    public DateTime? ModifyDate { get; set; }
}
