using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class LeaveOdlimitDesignationWise
{
    public int? CmpId { get; set; }

    public int? LeaveId { get; set; }

    public int? Id { get; set; }

    public int? Odlimit { get; set; }

    public DateOnly? SystemDate { get; set; }
}
