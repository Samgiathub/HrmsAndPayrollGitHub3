using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpDocDetailGet
{
    public decimal RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal DocId { get; set; }

    public string DocPath { get; set; } = null!;

    public string DocComments { get; set; } = null!;

    public DateTime? DateOfExpiry { get; set; }

    public string DocName { get; set; } = null!;
}
