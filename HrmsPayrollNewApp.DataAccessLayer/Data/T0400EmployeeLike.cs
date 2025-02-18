using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0400EmployeeLike
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal EmpLikeId { get; set; }

    public DateTime LikeDate { get; set; }

    public byte LikeFlag { get; set; }

    public byte NotificationFlag { get; set; }
}
