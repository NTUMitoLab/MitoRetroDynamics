using Distributed 

function add_procs()
    while nprocs() < length(Sys.cpu_info()) - 1 
        addprocs(1)
    end
end

add_procs()

@everywhere begin 
    using Pkg 
    Pkg.activate(@__DIR__)
    using Weave

    function get_notebooks()
        files = readdir(@__DIR__)

        filter!(x-> (occursin("ipynb",x) && !occursin("_checkpoints",x)),files)
        return files
    end

    function fname(fn;pfix="")
        return string(split(fn, ".")[1], pfix)
    end

    function mkdirp(dirpath)
        if !ispath(dirpath)
            mkdir(dirpath)
            @show "Create folder $(dirpath)"
        end
    end

    function change_content(orgPath, dstPath; ch= Dict("i_sol_PLACE_HOLDER=1"=>"i_sol_PLACE_HOLDER=2"))
        content = readlines(orgPath)
        for k in keys(ch)
            content = replace(content, k=>ch[k])
        end

        open(dstPath, "w") do io
            for i in content
                println(io,i )
            end
        end;
    end

    function test_sol_i(ntdir, pb, i)
        # convert ipynb to jl
        jlpath = joinpath(ntdir, fname(pb;pfix=".jl"))
        convert_doc(pb, jlpath)
        njlpath = fname(jlpath;pfix="_sol_$(i).jl")

        # Build new ipynb with sol i
        change_content(jlpath, njlpath;  ch= Dict("i_sol_PLACE_HOLDER=1"=>"i_sol_PLACE_HOLDER=$i","Pkg.activate(\"$(fname(pb))\")"=>"Pkg.activate(dirname(@__DIR__))" ))
        convert_doc(njlpath, fname(njlpath;pfix="_tmp.ipynb"))

        notebook(fname(njlpath;pfix="_tmp.ipynb"); out_path=fname(njlpath;pfix=".ipynb"), nbconvert_options="--allow-errors")

        # Remove auxiliary files
        rm(njlpath)
        rm(fname(njlpath;pfix="_tmp.ipynb"))
    end


    ipynbs = get_notebooks()
end
@show ipynbs


for pb in [ipynbs[2]]
    # Create notebooks folder
    ntdir = joinpath(fname(pb), "notebooks")
    mkdirp(ntdir)
    pmap(i->test_sol_i(ntdir, pb, i), 1:nprocs())
end

