using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055JobResponsibility
{
    public decimal JobRespId { get; set; }

    public decimal CmpId { get; set; }

    public decimal JobId { get; set; }

    public string? Responsibility { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
