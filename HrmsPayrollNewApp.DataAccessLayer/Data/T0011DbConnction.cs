using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0011DbConnction
{
    public decimal RowId { get; set; }

    public string? DatabaseName { get; set; }

    public string? UserId { get; set; }

    public string? Pwd { get; set; }

    public string? Connection { get; set; }

    public decimal? CmpId { get; set; }
}
