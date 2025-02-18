using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0001SchemeMaster
{
    public decimal ScmId { get; set; }

    public string Scheme { get; set; } = null!;

    public string? ModuleName { get; set; }

    public DateTime ModifyDate { get; set; }
}
