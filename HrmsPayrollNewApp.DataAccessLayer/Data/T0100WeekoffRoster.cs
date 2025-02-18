using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100WeekoffRoster
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public byte IsCancelWo { get; set; }

    public decimal? UserId { get; set; }

    public DateTime? SystemDate { get; set; }
}
