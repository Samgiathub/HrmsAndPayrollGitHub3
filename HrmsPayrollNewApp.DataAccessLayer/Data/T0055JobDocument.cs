using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055JobDocument
{
    public int DocId { get; set; }

    public decimal CmpId { get; set; }

    public decimal DocTypeId { get; set; }

    public decimal JobId { get; set; }

    public string FileName { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DocumentMaster DocType { get; set; } = null!;

    public virtual T0050JobDescriptionMaster Job { get; set; } = null!;
}
