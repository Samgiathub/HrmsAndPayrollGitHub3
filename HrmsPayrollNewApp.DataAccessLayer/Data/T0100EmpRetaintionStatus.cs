using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpRetaintionStatus
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public byte IsRetainOn { get; set; }

    public decimal? UserId { get; set; }

    public DateTime? SystemDateStart { get; set; }

    public DateTime? SystemDateEnd { get; set; }

    public int? TotRetainDays { get; set; }
}
