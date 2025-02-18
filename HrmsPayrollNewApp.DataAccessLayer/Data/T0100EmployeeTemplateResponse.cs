using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmployeeTemplateResponse
{
    public int EtrId { get; set; }

    public int? CmpId { get; set; }

    public int? EmpId { get; set; }

    public int? TId { get; set; }

    public int? FId { get; set; }

    public string? Answer { get; set; }

    public DateTime? CreatedDate { get; set; }

    public int? ResponseFlag { get; set; }
}
