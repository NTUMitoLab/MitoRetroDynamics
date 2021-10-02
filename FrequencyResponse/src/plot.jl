
"""
Figure meta 
"""
struct Fig
    fig 
    ax
    name
end

"""
Save function
    
filename
--------
- "path_dir/secName_fname.format"
"""
function save(f::Fig, secName, path_dir; format="pdf", transparent=true, bbox_inches = "tight", kwags...)
    isdir(path_dir) ? nothing : mkdir(path_dir)
    filename = string(secName,"_",f.name,".",format)
    path = joinpath(path_dir, filename)
    f.fig.savefig(path;transparent=true, bbox_inches = "tight", kwags... )
end

"""
Plot time-series data with summation of protein species.
"""
function plotSol(ax, sol,  n_pr, modelMeta::DynModel; 
                linewidth=4, input_color="blue", output_color="gray", 
                font=10, ylabel_output="", ylabel_input="Input\nMitochondrial Damage Signal (AU)", 
                xlabel="Time (sec)", ylim_input=[0.,1.], ylim_output=Nothing,title="")
    
   
    
    output = get_sum(sol, n_pr, modelMeta)
    input = get_sum(sol, modelMeta.input_i)

    
    # Plot Output
    ax.plot(sol.t, output, linewidth=linewidth, color=input_color)
    
    # Plot Input
    ax2 = ax.twinx()
    ax2.plot(sol.t, input, color=output_color)
    
    # Label and Ticks
    ax.set_xlabel(xlabel, fontsize=font)
    
    ax.set_ylabel(ylabel_output, fontsize=font)
    ax2.set_ylabel(ylabel_input, fontsize=font)
    
    ax.set_title(title)
    
    # Ticks
    ax.xaxis.set_ticks( round.([sol.t[1], sol.t[end]]) )

    # Set Output y axis
    if ylim_output != Nothing 
        ax.yaxis.set_ticks( round.([minimum(output), maximum(output)]) )
    else 
        ax.yaxis.set_ticks( round.([minimum( output), maximum(output)]) )
    end

    ax2.yaxis.set_ticks(ylim_input)
    
    
    ax.tick_params(direction="in")
    ax2.tick_params(direction="in")
    
    
    
end;


function plotSol(sol, n_pr, modelMeta::DynModel; figsize= (3,3) , kwags...)
    fig, ax = plt.subplots(figsize=figsize)
    ax = plotSol(ax, sol, n_pr, modelMeta; kwags...)
    return fig, ax
end

