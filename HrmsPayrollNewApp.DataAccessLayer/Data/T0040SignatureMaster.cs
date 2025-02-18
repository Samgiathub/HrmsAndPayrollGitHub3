using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SignatureMaster
{
    public decimal SignTypeId { get; set; }

    public decimal CmpId { get; set; }

    public string SignType { get; set; } = null!;

    public string SignName { get; set; } = null!;

    public string SignDesignation { get; set; } = null!;

    public string SignImageName { get; set; } = null!;

    public decimal SignDefId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
