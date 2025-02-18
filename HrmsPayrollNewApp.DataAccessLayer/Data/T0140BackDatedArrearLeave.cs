using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140BackDatedArrearLeave
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LeaveApprovalId { get; set; }

    public decimal ArrearDays { get; set; }

    public decimal PresentImportTranId { get; set; }

    public DateTime TimeStamp { get; set; }
}
