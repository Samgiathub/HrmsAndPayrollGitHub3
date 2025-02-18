using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040EventMaster
{
    public decimal EventId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string EventName { get; set; } = null!;

    public string? EventType { get; set; }

    public DateTime EventDate { get; set; }

    public string? EventRepeate { get; set; }

    public decimal? EventShow { get; set; }

    public string? ImageName { get; set; }

    public decimal? ShowAll { get; set; }

    public decimal? LoginId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
