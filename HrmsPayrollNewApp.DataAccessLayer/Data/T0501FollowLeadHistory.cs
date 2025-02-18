using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0501FollowLeadHistory
{
    public decimal TranId { get; set; }

    public decimal? LeadId { get; set; }

    public decimal? AssignedTo { get; set; }

    public DateTime? AssignedDate { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? ModifiedBy { get; set; }

    public DateTime? ModifiedDate { get; set; }
}
