using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200QuestionMaster
{
    public decimal QuestionId { get; set; }

    public decimal CmpId { get; set; }

    public string Question { get; set; } = null!;

    public string? Description { get; set; }

    public byte IsActive { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
