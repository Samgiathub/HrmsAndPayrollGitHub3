using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class UserActivityLog
{
    public int Id { get; set; }

    public int? CmpId { get; set; }

    public string? Privilege { get; set; }

    public int? EmpId { get; set; }

    public string? Action { get; set; }

    public DateTime? CreatedDate { get; set; }
}
