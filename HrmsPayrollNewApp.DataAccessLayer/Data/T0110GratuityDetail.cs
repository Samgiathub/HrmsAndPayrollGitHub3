using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110GratuityDetail
{
    public decimal GrDId { get; set; }

    public decimal GrId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal GrDCalcAmount { get; set; }

    public decimal GrDAmount { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0100Gratuity Gr { get; set; } = null!;
}
